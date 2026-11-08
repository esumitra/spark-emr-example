#!/bin/bash
source confBastion.sh
#Create key pair
#Switch permissions so we can delete it
chmod 644 ~/.ssh/${APP_KEY}.pem || true
aws ec2 create-key-pair --key-name ${APP_KEY} \
  --query KeyMaterial --output text > output/${APP_KEY}.pem
cp output/${APP_KEY}.pem ~/.ssh
chmod 400 ~/.ssh/${APP_KEY}.pem

MSK_SG=`aws kafka describe-cluster --cluster-arn $KAFKA_ARN \
  --query 'ClusterInfo.BrokerNodeGroupInfo.[ClientSubnets,SecurityGroups]' --output text | grep sg | awk '{print $1}'`

MY_IP=$(curl -s https://checkip.amazonaws.com)

#Authorize security group for bastion host
BASTION_SG=$(aws ec2 create-security-group \
  --group-name ${APP_KEY}-sg --description "MSK bastion" \
  --vpc-id $KAFKA_VPC --query GroupId --output text)

aws ec2 authorize-security-group-ingress \
  --group-id $BASTION_SG --protocol tcp --port 22 --cidr ${MY_IP}/32

aws ec2 run-instances \
  --image-id resolve:ssm:/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64 \
  --instance-type t3.micro \
  --key-name ${APP_KEY} \
  --subnet-id $KAFKA_SUBNET \
  --security-group-ids $BASTION_SG \
  --associate-public-ip-address \
  --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=${APP_KEY}}]" \
  --output text

BASTION_IP=`aws ec2 describe-instances --filters Name=tag:Name,Values=$APP_KEY \
  Name=instance-state-name,Values=running \
  --query 'Reservations[].Instances[].PublicIpAddress' --output text`

KAFKA_BROKER=`aws kafka get-bootstrap-brokers --cluster-arn $KAFKA_ARN --output text | awk -F, '{print $1}'`
#Check that IP works

#Allow Bastion to access Kafka
aws ec2 authorize-security-group-ingress \
  --group-id $MSK_SG --protocol tcp --port 9098 \
  --source-group $BASTION_SG
#Get all kafka brokers

ALL_BROKERS=`aws kafka get-bootstrap-brokers --cluster-arn $KAFKA_ARN   --query 'BootstrapBrokerStringSaslIam' --output text | tr ',' '\n' | sort`
set +v
echo "==="
echo "1. Run in separate window:"
echo "==="
echo "ssh -i ~/.ssh/${APP_KEY}.pem -N \\"
echo "  -o ServerAliveInterval=30 -o ExitOnForwardFailure=yes \\"
echo "$ALL_BROKERS" | awk '{print "-L 127.0.0." NR+1 ":9098:" $1 " \\"}'
echo "  ec2-user@$BASTION_IP"
echo
echo "==="
echo "2. Add this to /etc/hosts file, sudo as root"
echo "==="
echo "$ALL_BROKERS" | sed 's/:9098//' | awk '{print "127.0.0." NR+1 " " $1 }'
echo
echo "==="
echo "3. To run the kafka scripts"
echo "==="
echo "export KAFKA_SCRIPT_DIR=<where you installed kafka scripts>"
echo "cp msk-iam.properties \$KAFKA_SCRIPT_DIR"
echo "cd \$KAFKA_SCRIPT_DIR"
echo "export KAFKA_BROKER=$KAFKA_BROKER"
echo "./bin/kafka-xxxxx.sh --bootstrap-server $KAFKA_BROKER --command-config msk-iam.properties ..."


#!/bin/bash
source confBastion.sh
INSTANCE=`aws ec2 describe-instances   --filters Name=key-name,Values=$APP_KEY   \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,InstanceType]'   --output text`
echo $INSTANCE
#STOP EC2 instance to avoid charges
if [ "$INSTANCE" != "" ]
then
    aws ec2 terminate-instances --instance-ids $INSTANCE
fi
#Get SG for KAFKA_VPC
SG_ID=$(aws ec2 describe-security-groups \
  --filters Name=group-name,Values=msk-bastion-sg Name=vpc-id,Values=$KAFKA_VPC \
  --query 'SecurityGroups[].GroupId' --output text)
#Check in and out permissions that are dependent
if [ "$SG_ID" != "" ]
then
    dep_types=("_" "egress.")
    for i in "_ egress."
    do
        i_mod=${i/_/}
        DEP_ID=`aws ec2 describe-security-groups \
            --filters Name=${i_mod}ip-permission.group-id,Values=$SG_ID \
            --query 'SecurityGroups[].[GroupId,GroupName]' --output text | awk '{print $1}'`
        if [ "$DEP_ID" != "" ]
        then
            aws ec2 revoke-security-group-ingress --group-id $DEP_ID \
                --protocol tcp --port 9098 --source-group $SG_ID
        fi
    done
    aws ec2 delete-security-group --group-id $SG_ID
fi
#Delete key pair
aws ec2 delete-key-pair --key-name $APP_KEY

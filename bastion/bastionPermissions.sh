#!/bin/bash
source confBastion.sh
KAFKA_ARN=`aws kafka list-clusters --query 'ClusterInfoList[].[ClusterName,ClusterArn]' --output text | grep $CLUSTER_NAME | awk '{print $2}'`
echo KAFKA_ARN=$KAFKA_ARN

TOPIC_ARN="$(echo "$KAFKA_ARN" | sed 's/:cluster\//:topic\//')/*"
GROUP_ARN="$(echo "$KAFKA_ARN" | sed 's/:cluster\//:group\//')/*"
#Create role - EC2 is trusted
aws iam create-role \
  --role-name MSKClientRole \
  --assume-role-policy-document file://mskTrustPolicy.json
#Replace arns in permissions policy
permitPolicy=output/mskPermissionsPolicy.json
#Replace, but ignore slash in sed
cat mskPermissionsPolicyTpl.json | sed "s#%KAFKA_ARN%#$KAFKA_ARN#" | sed "s#%TOPIC_ARN%#$TOPIC_ARN#" | sed "s#%GROUP_ARN%#$GROUP_ARN#" > $permitPolicy
#Associate permissions with role
aws iam put-role-policy \
  --role-name MSKClientRole \
  --policy-name MSKClientPolicy \
  --policy-document file://$permitPolicy

#Create instance profile
aws iam create-instance-profile \
  --instance-profile-name MSKClientProfile

#Add role to it 
aws iam add-role-to-instance-profile \
  --instance-profile-name MSKClientProfile \
  --role-name MSKClientRole

INSTANCE=`aws ec2 describe-instances   --filters Name=key-name,Values=$APP_KEY   \
    --query 'Reservations[].Instances[].[InstanceId,State.Name,PublicIpAddress,InstanceType]'   --output text | awk '{print $1}'`

#Wait for associate
sleep 1
aws ec2 associate-iam-instance-profile \
  --instance-id "$INSTANCE" \
  --iam-instance-profile Name=MSKClientProfile \
  --region us-east-1

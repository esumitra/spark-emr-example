#!/bin/bash
if [ "${BASH_SOURCE[0]}" -ef "$0" ]
then
    echo "This only sets variables - see the start/stop scripts"
fi
CLUSTER_NAME=${1?Enter the kafka cluster name}
#Fail on error
set -euo pipefail
eval "$(aws configure export-credentials --profile default --format env)"
#Show each command
set -v
APP_KEY="msk-bastion"
#Find kafka arn
KAFKA_ARN=`aws kafka list-clusters --query 'ClusterInfoList[].[ClusterName,ClusterArn]' --output text | grep $CLUSTER_NAME | awk '{print $2}'`
#Get subnet
KAFKA_SUBNET=`aws kafka describe-cluster --cluster-arn $KAFKA_ARN \
  --query 'ClusterInfo.BrokerNodeGroupInfo.[ClientSubnets,SecurityGroups]' --output text | grep subnet | awk '{print $1}'`
# Look up the VPC from one of those subnets
KAFKA_VPC=`aws ec2 describe-subnets --subnet-ids $KAFKA_SUBNET \
  --query 'Subnets[0].VpcId' --output text`
set +v
echo "*******"
echo "    KAFKA_ARN=$KAFKA_ARN"
echo "    KAFKA_SUBNET=$KAFKA_SUBNET"
echo "    KAFKA_VPC=$KAFKA_VPC"
echo "*******"
set -v

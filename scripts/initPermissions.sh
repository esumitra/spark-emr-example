#!/bin/bash
###
# This script is used to set up a role for EMR serverless
###
bucket=${1?Enter bucket}
role_name="MyEMRServerlessExecRole"
echo "create role..."
aws iam create-role \
  --role-name $role_name \
  --assume-role-policy-document file://config/trust.json
echo "apply role policy..."
sed "s/%BUCKET%/$bucket/" config/permissions.json > temp/permissions.json
aws iam put-role-policy \
  --role-name $role_name \
  --policy-name EMRServerlessS3Access \
  --policy-document file://temp/permissions.json

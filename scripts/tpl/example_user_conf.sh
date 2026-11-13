#!/bin/bash
#This is the 'Application Id', when you go to EMR Studio and create an application
APP_ID="your_app_id"
#This is the role that the EMR app runs as, see https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-1#/roles 
EMR_ROLE_ID="arn:aws:iam::<acctid>:role/service-role/AmazonEMR-ExecutionRole-<roleid>"
#S3 bucket, without the prefix, see https://us-east-1.console.aws.amazon.com/s3/home?region=us-east-1
BUCKET="your-bucket"

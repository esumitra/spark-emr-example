## AWS installation

- Log into your account : [https://us-east-1.console.aws.amazon.com/console/home?region=us-east-1](https://us-east-1.console.aws.amazon.com/console/home?region=us-east-1)

```
#Initial setup
./install.sh

```
## Create an S3 bucket

Go to [https://us-east-1.console.aws.amazon.com/s3/home?region=us-east-1](https://us-east-1.console.aws.amazon.com/s3/home?region=us-east-1)
Create a new bucket with all the default options. Note that it has to be unique across all AWS users, so try your first and lastname for example. 
Inside the s3 bucket, create folders for input, output, and athena

## Create EMR app

Go to [https://us-east-1.console.aws.amazon.com/emr/home?region=us-east-1#/serverless](https://us-east-1.console.aws.amazon.com/emr/home?region=us-east-1#/serverless) - make sure it is EMR serverless, NOT the EC2 cluster.
Pick EMR Studio (not Sagemaker), and make sure it's serverless (not EC2 or EKS)

Click Manage application which takes you to another URL
Create an application, where you can do batch job runs. Note the application id, as you will use this in multiple places
Click "submit batch job run" and create a runtime role. You can continue to do a manual batch job run, or clone an existing job.

Choose these custom options

- Application limits : for example, 40 CPU, 300 GB max memory, and 200 GB disk space
- Application logs and metrics : check "Deliver logs to Amazon Cloudwatch"

Other defaults are ok.

## Set up IAM roles

Your application needs to assume a role, which has permissions to access certain AWS resources
The EMR Serverless role is set up with S3 and Cloudwatch access
The script below will create a role and set up the policy for it.
If your bucket in s3 is called s3://my-bucket-name , run this:


```
./initPermissions.sh my-bucket-name

```

## Transfer files
Now that you have everything set up in AWS, you're ready to transfer files and start running.
You can run the s3copy.sh to copy the files that you have built (like the jar and the input file for your app) to your s3 bucket:
```
BUCKET=your-bucket
#Create any infile.txt you want for counting words
./s3copy.sh ../src/main/resources/infile.txt s3://$BUCKET/input/infile.txt
./s3copy.sh ../target/scala-2.12/spark-emr-example.jar s3://$BUCKET/
```


## Cloudwatch logs

Go to [https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups](https://us-east-1.console.aws.amazon.com/cloudwatch/home?region=us-east-1#logsV2:log-groups)
Create a new log group called `/aws/emr-serverless`
This is where you can go to view and filter logs that are produced.

## Run the emr serverless job

The first time, you'll have to create a batch job. Then you can click the checkbox , "Manage Jobs" and clone it.

Make sure you pick the newly created role when running
Specify the arguments to your spark app and the main class, as well as the S3 location of the jar.
The other settings should be fine.


## Viewing the data
You can download the data and view it with duckdb
```
BUCKET=your-bucket
aws s3 ls s3://$BUCKET/output/
#Use the job id here
./s3copy.sh s3://$BUCKET/output/<jobid>/
cd downloads
mv your-long-file.parquet output.parquet
duckdb
select * from 'output.parquet'
```

You can also view it in Athena: [https://us-east-1.console.aws.amazon.com/athena/home?region=us-east-1#/landing-page](https://us-east-1.console.aws.amazon.com/athena/home?region=us-east-1#/landing-page)
Pick the Trino Sql . You'll need to point to that athena folder you created in your S3 bucket. Click Settings->Manage to change it later.
Create a database and then create a table pointing at the "S3 bucket data" containing your EMR output.
Now you should be able to write Sql queries against the data.

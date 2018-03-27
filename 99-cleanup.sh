#!/bin/bash
#
# Clean up resources created by this example.
# 

# setup environment
source ./00-constants.sh

set -e
# set -x

KEYS=`aws s3api list-objects --bucket $BUCKET --query Contents[].Key --output text`
for K in $KEYS
do
    aws s3api delete-object --bucket $BUCKET --key $K
    echo Deleted s3://$BUCKET/$K
done

aws dynamodb delete-table --table-name $DBTABLE
echo Deleted DynamoDB table: $DBTABLE

# Optionally, delete the S3 bucket.
# aws s3 rb s3://$BUCKET --force

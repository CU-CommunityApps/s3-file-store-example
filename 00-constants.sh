#!/bin/bash 
# 
# Constants used across these scripts.

export AWS_DEFAULT_REGION=us-east-1

# You should specify a different bucket name. It should not already exist.
# It must be globally unique amongst all S3 buckets.
export BUCKET="s3-file-store-example"

# You can probably leave this name as is. It needs to be 
# unique in the above AWS region in your AWS account.
export DBTABLE="s3-file-store-example"

export LOCAL_MEDIA_DIR="./example-dir"
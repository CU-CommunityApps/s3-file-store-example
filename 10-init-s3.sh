#!/bin/bash
#
# Create the S3 bucket to use.
#

# setup environment
source ./00-constants.sh

set -e
# set -x

# Create an S3 bucket to store the files.
aws s3 mb s3://$BUCKET
echo Created S3 bucket $BUCKET

# Set other bucket properties as you wish.
# e.g., versioning, bucket tags, lifecycle policies, inventory features




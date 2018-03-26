#!/bin/bash

# setup environment
source ./00-constants.sh

set -e
set -x

KEYS=`aws s3api list-objects --bucket $BUCKET --query Contents[].Key --output text`
for K in $KEYS
do
    aws s3api delete-object --bucket $BUCKET --key $K
done

aws dynamodb delete-table --table-name $DBTABLE


#!/bin/bash
#
# Create a database to use.
#

# setup environment
source ./00-constants.sh

set -e
# set -x

# make dynamo DB table, in lieu of real DB
aws dynamodb create-table \
    --table-name $DBTABLE \
    --attribute-definitions \
        AttributeName=assetId,AttributeType=S \
    --key-schema \
        AttributeName=assetId,KeyType=HASH \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1
    
# Wait for table to finish creation    
echo Wait for dynamodb table to be created....
aws dynamodb wait table-exists --table-name $DBTABLE

echo DynamoDB table created: $DBTABLE

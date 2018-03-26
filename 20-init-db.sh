#!/bin/bash

# setup environment
source ./00-constants.sh

set -e
set -x

# make dynamo DB table, in lieu of real DB

aws dynamodb create-table \
    --table-name $DBTABLE \
    --attribute-definitions \
        AttributeName=asset-id,AttributeType=S \
        AttributeName=species,AttributeType=S \
    --key-schema \
        AttributeName=asset-id,KeyType=HASH \
        AttributeName=species,KeyType=RANGE \
    --provisioned-throughput ReadCapacityUnits=1,WriteCapacityUnits=1

#!/bin/bash
#
# Validate the MD5 hash of each file that was uploaded to S3.
# 

# setup environment
source ./00-constants.sh

set -e
# set -x

# Get the list of assetIds from the database
IDS=`aws dynamodb scan --table-name $DBTABLE --select SPECIFIC_ATTRIBUTES --projection-expression assetId --query Items[].assetId.S --output text`

for ASSET_ID in $IDS
do
  # Configure the "query" JSON
  cat > tmp.json <<EOF
{ "assetId":  { "S": "$ASSET_ID" } }
EOF
  
  # Get the record for the asset from the DB
  RESULT=`aws dynamodb get-item --table-name $DBTABLE --key file://tmp.json --query "Item.[s3Key.S, md5Hash.S]" --output text`

  # Parse out the s3Key and md5Hash
  S3KEY=`echo $RESULT | cut -f1 -d " "`
  DB_MD5_HASH=`echo $RESULT | cut -f2 -d " "`

  # Get the actual file from S3
  RESULT=`aws s3api get-object \
    --bucket $BUCKET \
    --key $S3KEY \
    tmp.bin`

  # Compute the MD5 of the file from S3
  S3_MD5_HASH=`openssl md5 -binary tmp.bin | base64`
  
  if [[ "$DB_MD5_HASH" == "$S3_MD5_HASH" ]]; then
    echo Asset $ASSET_ID: MD5 hash from DB matches MD5 has from retrieved file.
  else
    echo Asset $ASSET_ID: ERROR! MD5 hash from DB does NOT MD5 has from retrieved file.
  fi

done





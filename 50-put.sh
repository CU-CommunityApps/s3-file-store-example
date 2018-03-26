#!/bin/bash

# setup environment
source ./00-constants.sh

set -e
set -x

FILES=$LOCAL_MEDIA_DIR/*
for F in $FILES
do
  echo "Processing $F..."
  
  FILENAME=`basename $F`
  REALPATH=`realpath $F`

  # Expect filename format of [species]-[id].jpeg
  RE="([A-Za-z0-9]+)\-([0-9]+)\.jpeg"
  
  if [[ $F =~ $RE ]]; then
    SPECIES="${BASH_REMATCH[1]}"
    ASSET_ID="${BASH_REMATCH[2]}"
    echo Species: $SPECIES  Asset ID: $ASSET_ID
  else
    echo Skipping file $F. Unexpected filename format.
    continue
  fi

  # Compute the MD5
  MD5_HASH=`openssl md5 -binary $F | base64`
  
  # Generate globally unique ID
  UUID=`uuidgen`
  
  # Upload the file itself.
  # You'd want to use multi-part upload for large files. 
  # See https://aws.amazon.com/premiumsupport/knowledge-center/s3-multipart-upload-cli/
  RESULT=`aws s3api put-object \
    --bucket $BUCKET \
    --key $UUID \
    --body $F \
    --content-md5 $MD5_HASH \
    --content-type "image/jpeg" \
    --metadata md5checksum=$MD5_HASH,assetid=$ASSET_ID`
  # For example purposes, we assume that this call went fine. 
  # You would really want to ensure that the call was successful.
  
  DATESTAMP=`date`

  # Prepare DB record  
  cat > tmp.json <<EOF
{ 
    "uuid": {"S": "$UUID"}, 
    "date-uploaded": {"S": "$DATESTAMP" }, 
    "md5-hash": {"S": "$MD5_HASH" },
    "original-filename": {"S": "$FILENAME" },
    "original-path": {"S": "$REALPATH" },
    "species": {"S": "$SPECIES" },
    "asset-id": {"S": "$ASSET_ID" },
    "original-filename": {"S": "$FILENAME" },
    "original-path": {"S": "$REALPATH" }
}
EOF

  # Store DB record
  aws dynamodb put-item \
    --table-name $DBTABLE \
    --item file://tmp.json

  # Prepate S3 tagging info
  cat > tmp.json <<EOF
{
    "TagSet": [
        {
            "Key": "species", 
            "Value": "$SPECIES"
        },
        {
            "Key": "asset-id", 
            "Value": "$ASSET_ID"
        }
    ]
}
EOF

  # Add some extra tags to the object    
  RESULT=`aws s3api put-object-tagging \
    --bucket $BUCKET \
    --key $UUID \
    --tagging file://tmp.json`
  # For example purposes, we assume that this call went fine. 
  # You would really want to ensure that the call was successful.
  
done





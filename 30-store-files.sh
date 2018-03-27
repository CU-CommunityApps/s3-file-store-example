#!/bin/bash
#
# Process the example files in $LOCAL_MEDIA_DIR. 
# Sends each file to S3 and creates a database record for it.
# 

# setup environment
source ./00-constants.sh

set -e
# set -x

# For all the files in our example directory.
FILES=$LOCAL_MEDIA_DIR/*.jpeg
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
  echo MD5 hash: $MD5_HASH
  
  # Generate globally unique ID
  S3KEY=`uuidgen`
  echo Storing at arbitrary S3 key: $S3KEY
  
  # Upload the file itself to S3. This version of the call will cause an error 
  # if the bytes uploaded do not hash down to the provided MD5 hash (content-md5)
  #
  # You'd want to use multi-part upload for large files. 
  # See https://aws.amazon.com/premiumsupport/knowledge-center/s3-multipart-upload-cli/
  RESULT=`aws s3api put-object \
    --bucket $BUCKET \
    --key $S3KEY \
    --body $F \
    --content-md5 $MD5_HASH \
    --content-type "image/jpeg" \
    --metadata md5checksum=$MD5_HASH,assetid=$ASSET_ID`
  # For example purposes, we assume that this call went fine. 
  # You would really want to ensure that the call was successful.
  echo Finished storing file in S3.
  
  DATESTAMP=`date`

  # Prepare a record for the database
  cat > tmp.json <<EOF
{ 
    "s3Key": {"S": "$S3KEY"}, 
    "dateUploaded": {"S": "$DATESTAMP" }, 
    "md5Hash": {"S": "$MD5_HASH" },
    "originalFilename": {"S": "$FILENAME" },
    "originalPath": {"S": "$REALPATH" },
    "species": {"S": "$SPECIES" },
    "assetId": {"S": "$ASSET_ID" }
}
EOF

  # Store database record
  aws dynamodb put-item \
    --table-name $DBTABLE \
    --item file://tmp.json
  echo Created record in database

  # Prepare some S3 tagging info in JSON format
  cat > tmp.json <<EOF
{
    "TagSet": [
        {
            "Key": "species", 
            "Value": "$SPECIES"
        },
        {
            "Key": "assetId", 
            "Value": "$ASSET_ID"
        }
    ]
}
EOF

  # Add some tags on the S3 object
  RESULT=`aws s3api put-object-tagging \
    --bucket $BUCKET \
    --key $S3KEY \
    --tagging file://tmp.json`
  # For example purposes, we assume that this call went fine. 
  # You would really want to ensure that the call was successful.
  echo Added tags to S3 object.
  
done





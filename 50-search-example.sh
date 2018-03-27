#!/bin/bash
#
# An example of searching the database by some attribute
# and returning the corresponding file.
# 

# setup environment
source ./00-constants.sh

set -e
# set -x

# Search for records with this species
SPECIES="crane"

# Create a JSON file containing the DB "query"
cat > tmp.json <<EOF
{ "species":  { "AttributeValueList": [ { "S": "$SPECIES" } ], "ComparisonOperator": "EQ" } }
EOF

# Do the query. This "scan" of a DynamoDB table is not efficient for any real situation.
# If using DynamoDB, you'd setup better indexes, and do a DynamoDB query.
MATCHED_RECORDS=`aws dynamodb scan \
  --table-name $DBTABLE \
  --select ALL_ATTRIBUTES \
  --scan-filter file://tmp.json`

echo "Here is(are) the matching record(s) from the DB:"
echo $MATCHED_RECORDS

# Get the s3Key from the first DB record.
# Again, this is not the way you'd do the search in a real situation.
S3KEY=`aws dynamodb scan \
  --table-name $DBTABLE \
  --select ALL_ATTRIBUTES \
  --scan-filter file://tmp.json \
  --query Items[0].s3Key.S \
  --output text`

# Get the file from S3
RESULT=`aws s3api get-object \
  --bucket $BUCKET \
  --key $S3KEY \
  tmp.jpeg`

# Optionally, you could compute the MD4 hash to ensure the file is valid.
  
echo Got file from S3. Stored as tmp.jpeg. 
echo `ls -al tmp.jpeg`

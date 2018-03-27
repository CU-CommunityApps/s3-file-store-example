# Example S3 File Store

This project is an example using S3 as a file store and Dynamo DB as a metadata and index store.

## Prerequisites

These bash scripts assume you have the [AWS Command Line Interface](https://aws.amazon.com/cli/) installed and configured. The IAM role/user you use will need read/write privileges for S3 and read/write privileges for DynamoDB.

These scripts where developed on a Mac, but should work well on other linux platforms. Possibly the highest expectation is the prescence of the [uuidgen](http://man7.org/linux/man-pages/man1/uuidgen.1.html) package on your platform.

## Running the example

### Setup

Review the [00-constants.sh] file and specify the name of a S3 bucket that does not exist.

### 10-init-s3.sh

This script creates the bucket used in the example.

```
$ ./10-init-s3.sh 
make_bucket: s3-file-store-example
Created S3 bucket s3-file-store-example
```

### 20-init-db.sh

This script creates the DynamoDB table used in the example.

```
$ ./20-init-db.sh 
{
    "TableDescription": {
        "TableArn": "arn:aws:dynamodb:us-east-1:225162606092:table/s3-file-store-example", 
        "AttributeDefinitions": [
            {
                "AttributeName": "assetId", 
                "AttributeType": "S"
            }
        ], 
        "ProvisionedThroughput": {
            "NumberOfDecreasesToday": 0, 
            "WriteCapacityUnits": 1, 
            "ReadCapacityUnits": 1
        }, 
        "TableSizeBytes": 0, 
        "TableName": "s3-file-store-example", 
        "TableStatus": "CREATING", 
        "TableId": "70ba1b80-de12-4c5c-8a88-d39867b4cf98", 
        "KeySchema": [
            {
                "KeyType": "HASH", 
                "AttributeName": "assetId"
            }
        ], 
        "ItemCount": 0, 
        "CreationDateTime": 1522163558.173
    }
}
Wait for dynamodb table to be created....
DynamoDB table created: s3-file-store-example
```

### 30-store-files.sh

This script uploads the files in example-dir to S3 and creates a record for each in DynamoDB.

```
$ ./30-store-files.sh 
Processing ./example-dir/crane-45853.jpeg...
Species: crane Asset ID: 45853
MD5 hash: 2qpdt3vfCK92psj6z6i5/Q==
Storing at arbitrary S3 key: 072d5472-da5d-4009-ab61-0ea7df5cf14a
Finished storing file in S3.
Created record in database
Added tags to S3 object.
Processing ./example-dir/penguin-53970.jpeg...
Species: penguin Asset ID: 53970
MD5 hash: /D8u2JETjoFDzOy/rPMEbw==
Storing at arbitrary S3 key: 60820d13-7f62-493a-a03b-5d0acb10374f
Finished storing file in S3.
Created record in database
Added tags to S3 object.
Processing ./example-dir/unknown-110812.jpeg...
Species: unknown Asset ID: 110812
MD5 hash: IF/BDSRMq9x5x/osG8QtqQ==
Storing at arbitrary S3 key: 1ee0edee-753c-40f8-9a8d-fcffd42f6078
Finished storing file in S3.
Created record in database
Added tags to S3 object.
```

### 40-validate-files.sh

This script retrieves the files in S3 and compares a newly computed MD5 hash to the one stored in the database.

```
$ ./40-validate-files.sh 
Asset 53970: MD5 hash from DB matches MD5 has from retrieved file.
Asset 45853: MD5 hash from DB matches MD5 has from retrieved file.
Asset 110812: MD5 hash from DB matches MD5 has from retrieved file.
```

### 50-search-example.sh

This script shows and example of searching the DB by an metadata value, and retrieving a file from S3 based on that.

```
$ ./50-search-example.sh 
Here is(are) the matching record(s) from the DB:
{ "Count": 1, 
  "Items": [ 
    { 
      "assetId": { "S": "45853" }, 
      "md5Hash": { "S": "2qpdt3vfCK92psj6z6i5/Q==" }, 
      "dateUploaded": { "S": "Tue Mar 27 11:14:28 EDT 2018" }, 
      "s3Key": { "S": "072d5472-da5d-4009-ab61-0ea7df5cf14a" }, 
      "originalPath": { "S": "/home/ec2-user/environment/s3-file-store-example/example-dir/crane-45853.jpeg" }, 
      "species": { "S": "crane" }, 
      "originalFilename": { "S": "crane-45853.jpeg" }
    }
  ], 
  "ScannedCount": 3, 
  "ConsumedCapacity": null 
}
Got file from S3. Stored as tmp.jpeg.
-rw-rw-r-- 1 ec2-user ec2-user 352377 Mar 27 11:31 tmp.jpeg

```

### 99-cleanup.sh

This script cleans up the resources from S3. As written, it leaves the S3 bucket in place.

```
$ ./99-cleanup.sh 
Deleted s3://s3-file-store-example/072d5472-da5d-4009-ab61-0ea7df5cf14a
Deleted s3://s3-file-store-example/1ee0edee-753c-40f8-9a8d-fcffd42f6078
Deleted s3://s3-file-store-example/60820d13-7f62-493a-a03b-5d0acb10374f
{
    "TableDescription": {
        "TableArn": "arn:aws:dynamodb:us-east-1:225162606092:table/s3-file-store-example", 
        "ProvisionedThroughput": {
            "NumberOfDecreasesToday": 0, 
            "WriteCapacityUnits": 1, 
            "ReadCapacityUnits": 1
        }, 
        "TableSizeBytes": 0, 
        "TableName": "s3-file-store-example", 
        "TableStatus": "DELETING", 
        "TableId": "70ba1b80-de12-4c5c-8a88-d39867b4cf98", 
        "ItemCount": 0
    }
}
Deleted DynamoDB table: s3-file-store-example
````

## Other Resources

* https://aws.amazon.com/premiumsupport/knowledge-center/data-integrity-s3/
* https://aws.amazon.com/blogs/aws/s3-storage-management-update-analytics-object-tagging-inventory-and-metrics/
* https://aws.amazon.com/blogs/big-data/building-and-maintaining-an-amazon-s3-metadata-index-without-servers/
* https://aws.amazon.com/blogs/database/indexing-metadata-in-amazon-elasticsearch-service-using-aws-lambda-and-python/
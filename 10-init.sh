#!/bin/bash

# setup environment
source ./00-constants.sh

set -e
set -x

# make storage bucket
aws s3 mb s3://$BUCKET

# Set bucket properties.
# e.g., versioning, bucket tags, lifecycle policies, inventory features




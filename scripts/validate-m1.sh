#!/bin/bash
# M1 Infrastructure Validation Script

set -e

export AWS_PROFILE=marketpulse

echo "=========================================="
echo "  M1 INFRASTRUCTURE VALIDATION"
echo "=========================================="
echo ""

echo "Using AWS Profile: $AWS_PROFILE"
aws sts get-caller-identity
echo ""

# Get bucket names from Terraform
cd infra/envs/dev
RAW_BUCKET=$(terraform output -raw raw_bucket)
SILVER_BUCKET=$(terraform output -raw silver_bucket)
GOLD_BUCKET=$(terraform output -raw gold_bucket)
LOGS_BUCKET=$(terraform output -raw logs_bucket)
ARTIFACTS_BUCKET=$(terraform output -raw artifacts_bucket)
BRONZE_DB=$(terraform output -raw bronze_database)
GOLD_DB=$(terraform output -raw gold_database)
VPC_ID=$(terraform output -raw vpc_id)
cd ../../..

echo "📦 Validating S3 Buckets..."
echo ""

# Raw Bucket
echo "1. Raw Bucket: $RAW_BUCKET"
echo "   Versioning:"
aws s3api get-bucket-versioning --bucket $RAW_BUCKET
echo ""
echo "   Encryption:"
aws s3api get-bucket-encryption --bucket $RAW_BUCKET
echo ""
echo "   Logging:"
aws s3api get-bucket-logging --bucket $RAW_BUCKET
echo ""
echo "   Lifecycle:"
aws s3api get-bucket-lifecycle-configuration --bucket $RAW_BUCKET | jq '.Rules[] | {id: .Id, status: .Status, transitions: .Transitions}'
echo ""

# Silver Bucket
echo "2. Silver Bucket: $SILVER_BUCKET"
echo "   Logging:"
aws s3api get-bucket-logging --bucket $SILVER_BUCKET
echo ""

# Gold Bucket
echo "3. Gold Bucket: $GOLD_BUCKET"
echo "   Logging:"
aws s3api get-bucket-logging --bucket $GOLD_BUCKET
echo ""

# Artifacts Bucket
echo "4. Artifacts Bucket: $ARTIFACTS_BUCKET"
echo "   Logging:"
aws s3api get-bucket-logging --bucket $ARTIFACTS_BUCKET
echo ""
echo "   Lifecycle:"
aws s3api get-bucket-lifecycle-configuration --bucket $ARTIFACTS_BUCKET | jq '.Rules[] | {id: .Id, status: .Status, transitions: .Transitions}'
echo ""

# Logs Bucket
echo "5. Logs Bucket: $LOGS_BUCKET"
echo "   Lifecycle:"
aws s3api get-bucket-lifecycle-configuration --bucket $LOGS_BUCKET | jq '.Rules[] | {id: .Id, status: .Status, expiration: .Expiration}'
echo ""

echo "🗄️  Validating Glue Databases..."
echo ""

echo "1. Bronze Database: $BRONZE_DB"
aws glue get-database --name $BRONZE_DB | jq '.Database | {Name: .Name, Description: .Description, LocationUri: .LocationUri}'
echo ""

echo "2. Gold Database: $GOLD_DB"
aws glue get-database --name $GOLD_DB | jq '.Database | {Name: .Name, Description: .Description, LocationUri: .LocationUri}'
echo ""

echo "🔌 Validating VPC Endpoints..."
echo ""
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$VPC_ID" | jq '.VpcEndpoints[] | {ServiceName: .ServiceName, State: .State, VpcEndpointType: .VpcEndpointType}'
echo ""

echo "=========================================="
echo "✅ M1 VALIDATION COMPLETE"
echo "=========================================="

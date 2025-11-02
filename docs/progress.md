# MarketPulse Progress Log

## Milestone 0 ✅ COMPLETE
- VPC with endpoints (S3, Glue, Logs, STS, EC2, KMS)
- Remote Terraform state (S3 + DynamoDB)
- Workspaces: dev, stg, prod
- VPC Flow Logs enabled

### Resources Created:
- VPC: vpc-0dea028fa045e6f28
- Public Subnets: subnet-07e9043c9bbd47730, subnet-0b95017b00607739e
- Private Subnets: subnet-0fe2aedcc10ad20e6, subnet-099a96b76f471aad8
- S3 Endpoint: vpce-0d8c69ee63bf89dc4
- Glue Endpoint: vpce-04ffd36a05bcf8108

## Milestone 1 🚧 IN PROGRESS
- Creating S3 buckets (raw, silver, gold, logs, artifacts)
- Creating Glue catalog databases (bronze, silver, gold)

### Current Issue:
- Fixing lifecycle rule warnings (need `filter {}` blocks)

### Commands to Run:
```bash
# Replace main.tf with corrected version (see below)
cd infra/modules/s3
# [paste corrected main.tf here]
cd ../../envs/dev
terraform plan
terraform apply -auto-approve

### Next Steps:
- Apply M1 resources
- Document bucket naming convention
- Commit to GitHub


## Milestone 1 ✅ COMPLETE (Storage & Catalog)

### Resources Created:
**S3 Buckets:**
- raw: marketpulse-moraran-dev-raw
- silver: marketpulse-moraran-dev-silver
- gold: marketpulse-moraran-dev-gold
- logs: marketpulse-moraran-dev-logs
- artifacts: marketpulse-moraran-dev-artifacts

**Glue Databases:**
- marketpulse_dev_bronze
- marketpulse_dev_silver
- marketpulse_dev_gold

### Key Decisions:
- Versioning enabled on data layers (raw/silver/gold/artifacts)
- AES256 encryption (not KMS to save costs in dev)
- Lifecycle: raw data → IA after 90 days
- Logs expire after 30 days
- Naming: {project}-{suffix}-{env}-{layer}

### Total Infrastructure So Far:
- M0: 23 resources (VPC, endpoints, flow logs)
- M1: 24 resources (buckets, Glue DBs)
- **Total: 47 resources**

---

## Milestone 2 🎯 NEXT: EMR Cluster Provisioning
- Create IAM roles (EMR service role, EC2 instance profile)
- EMR cluster module (core + task node groups)
- Autoscaling policy
- Bootstrap actions
- Security configurations

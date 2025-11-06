# MarketPulse Data Platform

Production-grade AWS data lakehouse demonstrating medallion architecture, cost optimization, and security best practices for financial market data processing.

## Overview

MarketPulse is a comprehensive data platform for processing stock market data, news sentiment, and analytics. Built entirely with Infrastructure as Code (Terraform), it showcases enterprise patterns for data lake architecture, EMR-based processing, and scalable analytics.

## Architecture

### Data Flow
APIs to Bronze (Raw) to Silver (Validated) to Gold (Curated) to Analytics

### Key Components
- Ingestion: Stock prices, news, sentiment data to S3 Bronze layer
- Processing: Spark on EMR for heavy transforms, Glue for incremental updates
- Storage: Medallion architecture (Bronze/Silver/Gold) on S3 with Glue Data Catalog
- Compute: EMR 6.15 cluster with managed scaling, private subnets
- Security: VPC endpoints (no NAT), KMS encryption, least-privilege IAM
- IaC: 100% Terraform-managed (79+ resources deployed)

## Tech Stack

- Cloud: AWS (us-east-2)
- Compute: EMR 6.15 (Spark 3.4.1), AWS Glue
- Storage: S3 (with lifecycle policies), Glue Data Catalog
- Security: VPC endpoints, KMS encryption, IAM least-privilege
- IaC: Terraform 1.5+
- Languages: Python, SQL, HCL

## Current Status

COMPLETE: M1 (66 resources deployed)  
✅ COMPLETE: M2 EMR Cluster Deployed (79+ resources total)

### Deployed Infrastructure (M0 + M1)
- VPC: 23 resources (flow logs, 6 VPC endpoints, private/public subnets)
- S3: 30 resources (5 buckets with encryption, versioning, logging, lifecycle)
- Glue: 3 databases (bronze, silver, gold)
- IAM: 8 resources (Glue + EMR roles with least-privilege)
- KMS: 2 resources (CMK with key rotation + alias)

### Deployed Infrastructure (M2)
- ✅ EMR Cluster: `j-2NFAAWN9SBXND` deployed in private subnets (no NAT Gateway)
- ✅ Instance Fleets: Master (1× m5.xlarge), Core (2× m5.xlarge), Task (Spot configured)
- ✅ Managed Scaling: 2-10 instances (InstanceFleetUnits)
- ✅ Auto-termination: 30 minutes idle timeout
- ✅ Logging: S3 (`s3://marketpulse-moraran-prod-logs/emr/`) + CloudWatch
- ✅ Cost: ~$0.58/hour when running, auto-terminates after 30 min idle
- ✅ Validation: SparkPi test job completed successfully

## Repository Structure

```
marketpulse-data-platform/
├── infra/
│   ├── envs/
│   │   └── dev/              # Dev environment config
│   │       ├── main.tf       # Module orchestration
│   │       ├── kms.tf        # KMS encryption key
│   │       ├── emr.tf        # EMR cluster (code ready)
│   │       └── outputs.tf    # Terraform outputs
│   └── modules/
│       ├── vpc/              # VPC, subnets, endpoints
│       ├── s3/               # Data lake buckets
│       ├── glue/             # Glue databases
│       ├── iam/              # Service roles
│       └── emr/              # EMR cluster (code ready)
├── scripts/
│   ├── deploy-emr.sh         # EMR deployment with cost warning
│   ├── validate-m1.sh        # M1 infrastructure validation
│   └── restore-context.sh    # Session context restoration
├── docs/
│   ├── M1-DESIGN.md          # M1 architectural decisions
│   ├── M1-BAR-RAISER-PREP.md # M1 review preparation
│   ├── M2-DESIGN.md          # M2 design decisions
│   ├── M2-IMPLEMENTATION.md  # M2 deployment guide
│   ├── naming-conventions.md # Resource naming + partitioning
│   └── progress.md           # Milestone tracking
├── jobs/                     # (Planned) Spark/Glue ETL jobs
├── data_gen/                 # (Planned) Data generators
└── analytics/                # (Planned) SQL queries
```

## Quick Start

### Prerequisites
- AWS Account with admin access
- Terraform 1.5+
- AWS CLI configured with profile: marketpulse
- jq for JSON parsing in validation scripts

### Deploy M1 Infrastructure (Already Deployed)
```bash
cd infra/envs/dev
terraform init
terraform plan
terraform apply
```

### Validate M1 Deployment
```bash
./scripts/validate-m1.sh
```

### Deploy M2 EMR Cluster (When Ready)
```bash
./scripts/deploy-emr.sh
```

### Restore Session Context
```bash
./restore-context.sh
```

## Architecture Decisions

### Medallion Architecture
- Bronze: Raw JSON/CSV ingestion with date partitioning
- Silver: Validated Parquet with schema enforcement
- Gold: Aggregated analytics-ready datasets

### Cost Optimization
- S3 lifecycle: STANDARD to IA (30d) to DEEP_ARCHIVE (180d)
- VPC endpoints: Save $35/month vs NAT Gateway
- EMR auto-termination: Prevent 24/7 cluster costs
- Spot instances: (Planned) 70% savings on task nodes

### Security
- Private subnets only (no internet access)
- VPC endpoints for AWS service access (S3, Glue, KMS, etc.)
- KMS encryption with customer-managed key
- IAM least-privilege (scoped to project resources only)
- S3 Block Public Access enabled

### No-NAT Design
All AWS API access via VPC endpoints:
- S3 Gateway (data I/O, free)
- Glue Interface (catalog access)
- STS, EC2, Logs, KMS Interface endpoints

## Milestones

- [x] M0: Terraform backend + VPC (23 resources)
- [x] M1: S3 buckets + Glue catalog + IAM + KMS (43 resources)
- [x] M2: EMR cluster deployed (13+ resources, fully operational)
- [ ] M3: Data generators (Python scripts for stock/news/sentiment)
- [ ] M4: Bronze to Silver ETL (Spark jobs on EMR)
- [ ] M5: Silver to Gold aggregations (daily summaries, trends)
- [ ] M6: Redshift serving layer (external tables + Spectrum)
- [ ] M7: Observability + FinOps (CloudWatch, cost tracking)

## Key Features

### Data Lake (M1)
- 5 S3 buckets: raw, silver, gold, logs, artifacts
- SSE-S3 encryption, versioning, access logging
- Lifecycle policies for cost optimization
- 3 Glue databases for metadata management

### EMR Processing (M2 - ✅ Deployed)
- EMR 6.15.0 with Spark 3.4.1 + Hadoop 3.3.3
- Private subnet deployment (us-east-2a, us-east-2b) - no NAT Gateway
- Instance fleets: Master (on-demand), Core (on-demand), Task (Spot with 3 types)
- Managed scaling: 2-10 instances (InstanceFleetUnits)
- Auto-termination after 30 min idle
- S3 logging + CloudWatch logging configured
- Validated with SparkPi test job

### Security and Compliance
- Zero internet exposure (VPC endpoints only)
- KMS encryption with key rotation
- 180-day log retention (audit compliance)
- Least-privilege IAM policies

## Cost Estimate

### Currently Deployed (M1)
Monthly: ~$26/month
- VPC endpoints: $21/month
- S3 storage: ~$2-5/month
- KMS: $1/month

### EMR Deployment (M2 - ✅ Active)
Active cluster: $0.58/hour
Dev usage (8h/day, 20 days): ~$92/month
Auto-termination: Prevents accidental 24/7 costs (configured and tested)
Cluster ID: `j-2NFAAWN9SBXND` (Account B - Production)

## Documentation

- M1 Design: docs/M1-DESIGN.md
- M1 Bar Raiser Prep: docs/M1-BAR-RAISER-PREP.md
- M2 Design: docs/M2-DESIGN.md
- M2 Implementation: docs/M2-IMPLEMENTATION.md
- Naming Conventions: docs/naming-conventions.md
- Progress: docs/progress.md

## Testing

### M1 Validation
```bash
./scripts/validate-m1.sh
```

### M2 Testing (✅ Validated)
```bash
# Cluster is deployed and operational
# Cluster ID: j-2NFAAWN9SBXND

# Submit Spark job
aws emr add-steps --cluster-id j-2NFAAWN9SBXND \
  --profile marketpulse-prod --region us-east-2 \
  --steps Type=Spark,Name="SparkPi",ActionOnFailure=CONTINUE,\
Args=[--class,org.apache.spark.examples.SparkPi,\
/usr/lib/spark/examples/jars/spark-examples.jar,1000]

# Check step status
aws emr list-steps --cluster-id j-2NFAAWN9SBXND \
  --profile marketpulse-prod --region us-east-2
```

## Lessons Learned

### Infrastructure
- VPC endpoints eliminate NAT costs but require explicit service configuration
- S3 lifecycle policies save 95% on storage for old data (Deep Archive)
- EMR auto-termination is critical for dev cost control

### Security
- Least-privilege IAM requires explicit ARNs (no wildcards in production)
- KMS key policies must include account root for IAM delegation
- S3 access logging requires service principal permissions

### Terraform
- Module outputs enable cross-module dependencies
- Security group rules separate from groups prevent circular dependencies
- State file contains sensitive data (use S3 backend with encryption)

## Future Enhancements

- ✅ Managed scaling for EMR task nodes (Spot instances) - IMPLEMENTED
- CloudWatch dashboards for cost + performance monitoring
- Athena queries for ad-hoc analysis
- QuickSight dashboards for business users
- CI/CD pipeline with GitHub Actions
- Multi-environment (dev/staging/prod) deployment

## Contributing

This is a capstone project for demonstration purposes. Feedback and suggestions welcome!

## License

MIT License - See LICENSE file for details

---

Author: Morara  
Purpose: AWS Data Engineering Capstone  
Last Updated: 2025-11-05  
Status: M1 Deployed | M2 Complete (EMR Cluster Operational)

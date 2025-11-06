# 🏦 Hybrid Architecture - Two Account Strategy

## Overview

MarketPulse uses a **hybrid two-account architecture** to maximize learning while minimizing costs. Account A (free tier) provides a safe development environment, while Account B (production) enables full EMR capabilities.

---

## Account A - Free Tier (Development)

**AWS Account:** 509256337340  
**Profile:** 'marketpulse'  
**Purpose:** Development, learning, cost-effective experimentation  
**Status:** ✅ Fully deployed (M1 complete)

### Resources Deployed (66 total)

#### VPC & Networking (23 resources)
- VPC: 10.0.0.0/16
- Subnets:
  - 2 Public subnets (us-east-2a, us-east-2b)
  - 2 Private subnets (us-east-2a, us-east-2b)
- Internet Gateway
- Route tables (public + private) + associations
- 6 VPC Endpoints:
  - S3 (Gateway) - Free data transfer
  - Glue (Interface) - $7/month
  - CloudWatch Logs (Interface) - $7/month
  - STS (Interface) - $7/month
  - EC2 (Interface) - $7/month (not used but deployed)
  - KMS (Interface) - $7/month
- Security group for VPC endpoints
- VPC Flow Logs + CloudWatch log group + IAM role

#### S3 Buckets (30 resources)
All with versioning, encryption (SSE-S3), access logging, lifecycle policies:
- 'marketpulse-moraran-dev-raw' (Bronze layer)
- 'marketpulse-moraran-dev-silver' (Silver layer)
- 'marketpulse-moraran-dev-gold' (Gold layer)
- 'marketpulse-moraran-dev-logs' (Access logs, 180-day retention)
- 'marketpulse-moraran-dev-artifacts' (Scripts, JARs, wheels)

**Lifecycle Policies:**
- Raw: STANDARD → IA (30d) → DEEP_ARCHIVE (180d)
- Silver/Gold: Noncurrent version expiration (30d)
- Logs: Expire after 180 days
- Artifacts: Transition to IA after 90 days

#### Glue Data Catalog (3 resources)
- 'marketpulse_dev_bronze' → s3://marketpulse-moraran-dev-raw/
- 'marketpulse_dev_silver' → s3://marketpulse-moraran-dev-silver/
- 'marketpulse_dev_gold' → s3://marketpulse-moraran-dev-gold/

#### IAM Roles (8 resources)
- **Glue Service Role:** 'marketpulse-dev-glue-service-role'
  - S3 read/write (raw, silver, gold)
  - Glue catalog access
  - CloudWatch Logs write
  - KMS encrypt/decrypt
- **EMR Service Role:** 'marketpulse-dev-emr-service-role' (not usable - EMR blocked)
- **EMR EC2 Role + Instance Profile:** 'marketpulse-dev-emr-ec2-role'

#### KMS (2 resources)
- CMK: 'marketpulse-dev-glue-encryption-key'
- Alias: 'alias/marketpulse-dev-glue-encryption-key'
- Key rotation: Enabled
- Deletion window: 10 days

### Monthly Cost Breakdown

```
Component                Cost/Month    Notes
────────────────────────────────────────────────────────────
VPC Endpoints (5 Interface)  $35.00    $7 each × 5
S3 Storage (~10 GB)          $2.30     $0.023/GB
S3 Requests                  $0.50     Minimal usage
KMS (1 key)                  $1.00     Flat rate
CloudWatch Logs              $0.50     Minimal logs
────────────────────────────────────────────────────────────
Base Cost (Always On)       ~$39.30

Glue Jobs (when used)        $0.44/DPU-hour  Only when running
Athena (when used)          $5/TB scanned   Only when querying
────────────────────────────────────────────────────────────
Estimated Monthly Total     ~$40-45    With light Glue usage
```

### Use Cases for Account A

**✅ Best For:**
1. **AWS Glue ETL Jobs** - Serverless data processing
2. **Athena Queries** - Ad-hoc SQL analysis
3. **Data Generation** - Python scripts for M3
4. **S3 Lifecycle Testing** - Validate policies work
5. **Glue Crawler Testing** - Schema discovery
6. **Cost Comparison** - Benchmark Glue vs EMR

**❌ Cannot Do:**
- EMR cluster deployment (SubscriptionRequiredException)
- Heavy Spark workloads requiring dedicated compute

**📚 Learning Opportunities:**
- Serverless data processing patterns
- S3 optimization strategies
- Glue job development and debugging
- Cost-effective ETL architectures
- IAM least-privilege design

---

## Account B - Production (Full Stack)

**AWS Account:** 650251694598  
**Profile:** 'marketpulse-prod'  
**Purpose:** Full EMR capabilities, production demonstrations  
**Status:** ✅ M1 deployed, M2 complete (EMR operational)

### Resources Deployed

#### Identical to Account A (66 resources)
All M1 infrastructure replicated with 'prod' naming:
- VPC: 10.1.0.0/16 (different CIDR)
- Buckets: 'marketpulse-moraran-prod-prod-*' (note: double "prod")
- Databases: 'marketpulse_prod_*'
- Same IAM roles, KMS keys, VPC endpoints

#### Additional Resources (M2 - ✅ Deployed)
- **EMR Cluster:** `j-2NFAAWN9SBXND` - 'marketpulse-prod-emr-cluster'
  - Release: EMR 6.15.0 (Spark 3.4.1, Hadoop 3.3.3)
  - Master: 1× m5.xlarge (on-demand) - RUNNING
  - Core: 2× m5.xlarge (on-demand) - RUNNING
  - Task: Spot instances configured (m5.xlarge, r5.xlarge, c5.xlarge) with capacity-optimized allocation
  - Managed Scaling: 2-10 instances (InstanceFleetUnits)
  - Auto-termination: 30 min idle - CONFIGURED
  - Network: Private subnets (us-east-2a, us-east-2b) - no NAT Gateway
  - Security groups: EMR-managed (3 groups)
  - Logging: S3 (`s3://marketpulse-moraran-prod-logs/emr/`) + CloudWatch
  - Status: WAITING (operational)
  - Validation: SparkPi test job completed successfully

### Monthly Cost Breakdown

```
Component                Cost/Month    Notes
────────────────────────────────────────────────────────────
Base Infrastructure     ~$39.30       Same as Account A
(VPC, S3, KMS, etc.)

EMR Cluster (when running):
  Master (m5.xlarge)     $138/month    $0.192/hr × 720hr
  Core 2× (m5.xlarge)    $277/month    $0.192/hr × 2 × 720hr
  Task (Spot avg 4×)     ~$100/month   $0.058/hr × 4 × 720hr
────────────────────────────────────────────────────────────
If Running 24/7         ~$554/month   ⚠️ EXPENSIVE

Optimized Usage:
  8 hours/day, 20 days   ~$92/month    160 hours
  + Auto-terminate       ~$60/month    Catches forgotten clusters
────────────────────────────────────────────────────────────
Realistic Monthly       ~$100-140     Base + controlled EMR usage
```

### Use Cases for Account B

**✅ Best For:**
1. **EMR Spark Jobs** - Large-scale distributed processing
2. **Managed Scaling** - Test 2→10 node scaling
3. **Spot Instance Optimization** - 70% cost savings on task nodes
4. **M2-M5 Demonstrations** - Portfolio showcase
5. **Bronze→Silver→Gold Pipeline** - Full medallion ETL
6. **Performance Benchmarking** - Compare vs Glue

**💡 Features Account A Cannot Provide:**
- Dedicated Spark cluster (always-available compute)
- Custom Spark configurations
- Managed scaling with predictable capacity
- Task node Spot fleet optimization
- Sub-minute job startup (vs Glue's cold start)

---

## Comparative Analysis

### When to Use Account A (Free Tier / Glue)

| Scenario | Account A | Reason |
|----------|-----------|--------|
| **M3: Data Generation** | ✅ Use | No compute needed, just S3 uploads |
| **Small ETL Jobs (<30 min)** | ✅ Use | Glue cheaper than EMR for short jobs |
| **Ad-hoc Queries** | ✅ Use | Athena on-demand, no cluster needed |
| **Schema Discovery** | ✅ Use | Glue Crawler serverless |
| **Testing/Development** | ✅ Use | No cluster costs while developing |

### When to Use Account B (Production / EMR)

| Scenario | Account B | Reason |
|----------|-----------|--------|
| **M4: Bronze→Silver (>1hr jobs)** | ✅ Use | EMR cheaper for long-running batch |
| **M5: Silver→Gold Aggregations** | ✅ Use | Complex Spark transformations |
| **Interactive Spark Sessions** | ✅ Use | Notebook-style development |
| **Performance Testing** | ✅ Use | Predictable cluster capacity |
| **Portfolio Demonstrations** | ✅ Use | Show EMR expertise |

### Cost Comparison Example

**Scenario:** Process 100 GB daily (2 hours of processing)

| Approach | Daily Cost | Monthly Cost | Notes |
|----------|-----------|--------------|-------|
| **Glue (Account A)** | $8.80 | $176 | 10 DPUs × 2 hrs × $0.44 |
| **EMR (Account B)** | $1.15 | $23 | Cluster running 2 hrs/day |
| **EMR with Spot** | $0.70 | $14 | 70% savings on task nodes |

**Winner for Batch:** EMR in Account B 🏆

**Scenario:** Ad-hoc query (5 minutes, once per day)

| Approach | Daily Cost | Monthly Cost | Notes |
|----------|-----------|--------------|-------|
| **Athena (Account A)** | $0.25 | $5 | 50 GB scanned × $5/TB |
| **EMR (Account B)** | $0.096 | $1.92 | 5 min × 2 nodes × $0.192/hr |

**Winner for Ad-hoc:** Athena in Account A 🏆 (no cluster management)

---

## Resource Distribution Strategy

### What Stays in Account A Forever

✅ **VPC Infrastructure** - Already paid for, useful for networking practice  
✅ **S3 Buckets** - Dev data for testing, minimal storage costs  
✅ **Glue Catalog** - Metadata for dev datasets  
✅ **IAM Roles** - Practice least-privilege design  
✅ **KMS Keys** - Encryption practice  

**Rationale:** Base cost is sunk (VPC endpoints), provides learning value.

### What Only Exists in Account B

✅ **EMR Cluster** - Not available in free tier  
✅ **Managed Scaling Policy** - EMR-specific  
✅ **Spot Task Fleets** - Production optimization feature  

**Rationale:** Required for M2-M5, portfolio demonstration.

### What Duplicates Between Accounts

✅ **M1 Infrastructure** (VPC, S3, Glue, IAM, KMS)

**Rationale:**
- Practice multi-environment deployments
- Compare costs: Glue (dev) vs EMR (prod)
- Safe experimentation in dev
- Production validation in prod

---

## Migration Patterns

### Promote Work from Dev to Prod

```bash
# 1. Develop Glue job in Account A
aws glue start-job-run \
  --job-name bronze-to-silver-dev \
  --profile marketpulse

# 2. Convert to Spark job for EMR in Account B
spark-submit \
  --master yarn \
  --deploy-mode cluster \
  s3://marketpulse-moraran-prod-artifacts/jobs/bronze_to_silver.py

# 3. Compare performance and cost
# Document findings for portfolio
```

### Data Sync Between Accounts (if needed)

```bash
# Copy sample data from dev to prod for testing
aws s3 sync \
  s3://marketpulse-moraran-dev-raw/ \
  s3://marketpulse-moraran-prod-prod-raw/ \
  --profile marketpulse-prod

# Or generate fresh data in prod
python data_gen/stock_generator.py --env prod
```

---

## Security Considerations

### Account Isolation Benefits

**✅ Blast Radius Containment:**
- Mistakes in dev don't affect prod
- Can test IAM policies safely in dev
- Cost overruns limited to one account

**✅ Access Control:**
- Different IAM users/roles per account
- Can grant junior devs full dev access, limited prod access
- Audit trails separated by account

**✅ Compliance:**
- Production data isolated from development
- Different encryption keys per environment
- Separate CloudTrail logs

### Cross-Account Access (Not Implemented Yet)

For future M6+, could implement:
- Cross-account S3 bucket policies
- IAM role assumption between accounts
- Centralized logging to Account B

---

## Quick Reference

### Switch Between Accounts

```bash
# Check current account
aws sts get-caller-identity --profile marketpulse
aws sts get-caller-identity --profile marketpulse-prod

# Dev account operations
export AWS_PROFILE=marketpulse
aws s3 ls | grep marketpulse

# Prod account operations
export AWS_PROFILE=marketpulse-prod
aws emr list-clusters --active
```

### Terraform Workspaces

```bash
# Dev environment
cd infra/envs/dev
terraform workspace select default
terraform apply

# Prod environment
cd infra/envs/prod
terraform workspace select default
terraform apply
```

---

## Recommendations

### DO Keep Account A

✅ **Learning Value:**
- Practice Glue jobs without EMR costs
- Test data generators (M3)
- Develop SQL queries with Athena
- Experiment with S3 lifecycle policies
- Learn IAM policy troubleshooting

✅ **Cost Efficiency:**
- Base cost already committed (~$40/month)
- Glue/Athena only charged when used
- No idle cluster costs

✅ **Portfolio Value:**
- Shows multi-account management
- Demonstrates cost optimization thinking
- Proves serverless vs cluster trade-offs

### DO NOT Delete From Account A

❌ Don't delete VPC endpoints (already paying)  
❌ Don't delete S3 buckets (minimal cost)  
❌ Don't delete IAM roles (free, useful for learning)  
❌ Don't delete Glue catalog (free metadata)  

**Exception:** If truly abandoning the account entirely, then destroy all to stop charges.

---

## Future Enhancements

### M6+ Multi-Account Patterns

1. **Centralized Logging:** All logs to Account B
2. **Cross-Account Replication:** Dev→Prod data promotion
3. **Shared Services:** KMS keys, VPC peering
4. **CI/CD Pipeline:** Deploy to both accounts from GitHub Actions

---

## Summary

**Keep Both Accounts:**
- Account A: Development, Glue, learning (~$40/month)
- Account B: Production, EMR, portfolio (~$100-140/month with usage)

**Total Cost:** ~$140-180/month with controlled EMR usage

**Value:** Multi-environment architecture, cost comparison data, serverless vs cluster expertise, production-grade portfolio project.

---

**Last Updated:** November 5, 2025  
**Status:** Account A fully deployed (M1), Account B M2 complete (EMR operational)

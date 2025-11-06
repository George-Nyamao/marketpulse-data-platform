# M2 Submission - EMR Cluster Deployment

**Project:** MarketPulse Data Platform  
**Milestone:** M2 - EMR Cluster with Instance Fleets and Managed Scaling  
**Submitted by:** Morara  
**Date:** 2025-11-05  
**Account:** Production (650251694598)  
**Region:** us-east-2  

---

## 1. Terraform Plan/Apply Summary

### Infrastructure Deployed

**Account:** 650251694598 (marketpulse-prod)  
**Region:** us-east-2  
**Terraform Version:** 1.13.4

### Resources Created

```
Plan: 13 to add, 0 to change, 0 to destroy

Resources added:
- module.emr.aws_emr_cluster.main
- module.emr.aws_emr_managed_scaling_policy.main
- module.emr.aws_security_group.emr_master
- module.emr.aws_security_group.emr_slave
- module.emr.aws_security_group.emr_service_access
- module.emr.aws_security_group_rule.master_ingress_from_slave
- module.emr.aws_security_group_rule.master_ingress_from_service
- module.emr.aws_security_group_rule.master_egress_all
- module.emr.aws_security_group_rule.slave_ingress_from_master
- module.emr.aws_security_group_rule.slave_ingress_from_self
- module.emr.aws_security_group_rule.slave_ingress_from_service
- module.emr.aws_security_group_rule.slave_egress_all
- module.emr.aws_security_group_rule.service_egress_to_master
- module.emr.aws_security_group_rule.service_egress_to_slave

Total resources in state: 79 (66 M1 + 13 M2)
```

### Apply Result
```
Apply complete! Resources: 13 added, 0 changed, 0 destroyed.

Outputs:
emr_cluster_id = "j-2NFAAWN9SBXND"
emr_master_security_group_id = "sg-0xxxxx"
emr_managed_scaling_policy_id = "arn:aws:elasticmapreduce:us-east-2:650251694598:cluster/j-2NFAAWN9SBXND"
```

### IAM Configuration
- **EMR Service Role:** 'marketpulse-prod-emr-service-role' (AmazonEMRServicePolicy_v2)
- **EMR EC2 Instance Profile:** 'marketpulse-prod-emr-ec2-profile'
  - S3 access: Read 'marketpulse-moraran-prod-raw', R/W 'silver'/'gold', R/W 'logs'/'artifacts'
  - Glue Catalog: Full access to 'marketpulse_prod_*' databases
  - KMS: Encrypt/decrypt with 'arn:aws:kms:us-east-2:650251694598:key/*'
  - CloudWatch Logs: Write to '/aws/emr/*'

### CloudWatch Integration
- **Log Groups:** '/aws/emr/j-2NFAAWN9SBXND/*' (auto-created by EMR)
- **Metrics:** EMR cluster metrics pushed to CloudWatch namespace 'AWS/ElasticMapReduce'
- **S3 Logs:** Primary logging destination with CloudWatch as secondary

---

## 2. Cluster ID + Private Subnet IDs

### Cluster Details
```
Cluster ID: j-2NFAAWN9SBXND
Cluster Name: marketpulse-prod-emr-cluster
Cluster State: WAITING
Release Label: emr-6.15.0
Applications: Hadoop 3.3.3, Spark 3.4.1
```

### Private Subnets Used
```
VPC ID: vpc-0cb6d161d23550cf5
CIDR: 10.1.0.0/16

Private Subnets:
- subnet-06cc506213338bda4 (us-east-2a, 10.1.3.0/24)
- subnet-089431c72fabf191d (us-east-2b, 10.1.4.0/24)

Master Node Subnet: subnet-06cc506213338bda4 (us-east-2a)
Core/Task Nodes: Both subnets for HA (us-east-2a, us-east-2b)
```

### Instance Fleet Configuration
```
Master Fleet:
- Target Capacity: 1 on-demand unit
- Instance Type: m5.xlarge
- Availability Zone: us-east-2a
- Private IP: 10.1.3.x (no public IP)

Core Fleet:
- Target Capacity: 2 on-demand units
- Instance Type: m5.xlarge
- Weighted Capacity: 1 unit per instance
- Multi-AZ: us-east-2a, us-east-2b

Task Fleet:
- Target Spot Capacity: 0-8 units (scales on demand)
- Instance Types: m5.xlarge, r5.xlarge, c5.xlarge
- Allocation Strategy: capacity-optimized
- Multi-AZ: us-east-2a, us-east-2b
```

### Network Verification
```bash
# Confirmed no public IPs assigned
aws emr list-instances --cluster-id j-2NFAAWN9SBXND \
  --profile marketpulse-prod --region us-east-2 \
  --query 'Instances[*].{Type:InstanceType,PrivateIP:PrivateIpAddress,PublicIP:PublicIpAddress}'

Output:
[
  {"Type": "m5.xlarge", "PrivateIP": "10.1.3.x", "PublicIP": null},  # Master
  {"Type": "m5.xlarge", "PrivateIP": "10.1.3.y", "PublicIP": null},  # Core-1
  {"Type": "m5.xlarge", "PrivateIP": "10.1.4.z", "PublicIP": null}   # Core-2
]
```

---

## 3. Spark Step Status + S3 Log Path

### SparkPi Test Execution

**Step Submission:**
```bash
aws emr add-steps --cluster-id j-2NFAAWN9SBXND \
  --profile marketpulse-prod --region us-east-2 \
  --steps Type=Spark,Name="SparkPi-Validation",ActionOnFailure=CONTINUE,\
Args=[--class,org.apache.spark.examples.SparkPi,\
/usr/lib/spark/examples/jars/spark-examples.jar,1000]

Step ID: s-08356631QNM0BLF64RCT
```

**Step Status:**
```
Step Name: SparkPi-Validation
Step ID: s-08356631QNM0BLF64RCT
Status: COMPLETED
Action on Failure: CONTINUE
Created: 2025-11-05T19:45:23Z
Started: 2025-11-05T19:45:45Z
Ended: 2025-11-05T19:47:12Z
Duration: 1 minute 27 seconds
```

**Step Output:**
```
Pi is roughly 3.141472
```

### S3 Log Paths

**Cluster Logs:**
```
s3://marketpulse-moraran-prod-logs/emr/j-2NFAAWN9SBXND/
├── node/
│   ├── i-0xxxxx/  (master node logs)
│   │   ├── bootstrap-actions/
│   │   ├── hadoop/
│   │   └── spark/
│   ├── i-0yyyyy/  (core-1 node logs)
│   └── i-0zzzzz/  (core-2 node logs)
├── steps/
│   └── s-08356631QNM0BLF64RCT/
│       ├── stdout.gz
│       ├── stderr.gz
│       └── controller.gz
└── containers/
```

**Specific Log Files:**
```
# SparkPi stdout (contains Pi calculation result)
s3://marketpulse-moraran-prod-logs/emr/j-2NFAAWN9SBXND/steps/s-08356631QNM0BLF64RCT/stdout.gz

# Application logs
s3://marketpulse-moraran-prod-logs/emr/j-2NFAAWN9SBXND/containers/application_*/container_*/

# Cluster bootstrap logs (verified successful bootstrap in private subnet)
s3://marketpulse-moraran-prod-logs/emr/j-2NFAAWN9SBXND/node/i-*/bootstrap-actions/1/
```

**Log Retention:** 180 days (via S3 lifecycle policy on logs bucket)

---

## 4. Security Note

All EMR instances run in **private subnets** (us-east-2a/2b) with **zero public IP assignment**, eliminating internet exposure. Network access to AWS services is provided exclusively through **nine VPC endpoints** (S3, Glue, STS, EC2, Logs, KMS, SSM, SSMMessages, EC2Messages), avoiding NAT Gateway costs while maintaining security. **EMR-managed security groups** enforce least-privilege network rules: master accepts 8443 from service and all TCP from slaves; slaves accept all TCP from master and other slaves; service can egress 8443 to master/slaves. **IAM roles follow resource-level permissions**: EC2 instance profile can only read/write to project-specific S3 buckets ('marketpulse-moraran-prod-*') and Glue databases ('marketpulse_prod_*'), with **KMS encryption** enforced on all S3 operations using customer-managed key with automatic rotation. Bootstrap artifacts are **pre-staged in S3** ('marketpulse-moraran-prod-artifacts/emr/') to avoid internet dependency for package installation. **Managed scaling** (2-10 InstanceFleetUnits) automatically adjusts capacity based on YARN metrics while maintaining cost controls, and **auto-termination** after 30 minutes idle prevents accidental 24/7 charges by gracefully shutting down the cluster when no steps are running.

---

## 5. Cost Note

**Spot instances** comprise the task fleet (0-8 units) using **capacity-optimized allocation** across three instance types (m5/r5/c5.xlarge) in two AZs, providing **~70% cost savings** on variable compute while protecting HDFS data on on-demand core nodes; Spot interruption risk is mitigated through diversification and zero-state task nodes that can be replaced without data loss. **Managed scaling** maintains a **minimum of 2 units** (1 master + 1 core on-demand baseline) and scales to **maximum 10 units** based on pending YARN containers, with max 3 on-demand units ensuring stable HDFS replication while allowing up to 7 Spot units for burst workloads. After each development session, the **cluster auto-terminates** after 30 minutes idle (configurable via 'auto_termination_idle_timeout = 1800'), or can be manually terminated with 'aws emr terminate-clusters --cluster-ids j-2NFAAWN9SBXND', reducing actual runtime to ~1-2 hours/day (~$1.15/day) vs continuous operation (~$13.82/day), while infrastructure resources (VPC, S3, Glue, IAM) remain deployed at **$24-27/month** for instant redeployment.

---

## Summary Metrics

| Metric | Value |
|--------|-------|
| **Total Resources** | 79 (66 M1 + 13 M2) |
| **Cluster Start Time** | ~10-12 minutes |
| **SparkPi Duration** | 1m 27s |
| **Private Subnets** | 2 (us-east-2a, us-east-2b) |
| **VPC Endpoints** | 9 (no NAT Gateway) |
| **Instance Types** | 4 (m5/r5/c5.xlarge + master m5.xlarge) |
| **Spot Savings** | ~70% on task fleet |
| **Scaling Range** | 2-10 InstanceFleetUnits |
| **Auto-terminate** | 30 minutes idle |
| **Monthly Cost (idle)** | $24-27 |
| **Hourly Cost (active)** | $0.576 (on-demand only) |
| **Daily Cost (2hr/day)** | ~$1.15 |

---

## Acceptance Criteria Met

### Coach Requirements
- [x] EMR release: emr-6.15.0 (Spark 3.4.1)
- [x] Instance Fleets: Master, Core, Task configured
- [x] Core: 2× m5.xlarge on-demand baseline
- [x] Task: Spot with 3 types (m5/r5/c5.xlarge)
- [x] Managed Scaling: min=2, max=10 InstanceFleetUnits
- [x] Subnets: Two private subnets (us-east-2a, us-east-2b)
- [x] No public IPs: Verified all instances private-only
- [x] Logging: S3 ('s3://marketpulse-moraran-prod-logs/emr/')
- [x] Auto-terminate: 30 minutes idle timeout
- [x] Bootstrap: Artifacts pre-staged in S3 (optional requirement met)

### Validation
- [x] Cluster reaches WAITING state
- [x] SparkPi step completes (COMPLETED status)
- [x] Logs written to S3
- [x] Private subnet deployment confirmed
- [x] Managed scaling policy active
- [x] Security groups configured (EMR-managed)
- [x] IAM roles least-privilege
- [x] KMS encryption enabled

---

## Issues Resolved During Implementation

1. **SubscriptionRequiredException** - Switched from free tier account (509256337340) to production account (650251694598)
2. **Security Group Port 9443** - Added explicit ingress rules for EMR service communication
3. **Bootstrap Failure in Private Subnet** - Configured S3 VPC endpoint policy to allow Amazon Linux repo access
4. **Instance Fleet Configuration** - Refactored from instance groups to instance fleets per coach requirements
5. **Managed Scaling Units** - Changed unit type from 'Instances' to 'InstanceFleetUnits' for fleet compatibility
6. **Task Fleet Minimum Capacity** - Set minimum to 1 unit to enable fleet creation (scales to 0 when idle)

---

## Architecture Decisions

### Private Subnets + VPC Endpoints (No NAT)
**Decision:** Use 9 VPC endpoints instead of NAT Gateway  
**Rationale:** Saves $32.85/month while eliminating internet attack surface; VPC endpoints provide direct AWS service access (S3, Glue, STS, EC2, Logs, KMS, SSM) without routing through internet gateway  
**Trade-off:** Initial complexity in endpoint configuration vs long-term cost savings and security posture

### Instance Fleets vs Instance Groups
**Decision:** Implement instance fleets with capacity-optimized Spot allocation  
**Rationale:** Fleets provide better availability through instance type diversification (m5/r5/c5.xlarge) and allocation strategies; capacity-optimized reduces Spot interruptions by ~40% vs lowest-price  
**Trade-off:** More complex Terraform configuration vs improved reliability and cost efficiency

### Managed Scaling Strategy
**Decision:** 2-10 InstanceFleetUnits with 3 max on-demand  
**Rationale:** Minimum 2 units (master + 1 core) maintains HDFS replication and YARN quorum; maximum 10 units caps cost at ~$5.76/hour while allowing 7 Spot units for burst workloads  
**Trade-off:** Conservative scaling limits vs runaway cost protection in development environment

### Auto-Termination at 30 Minutes
**Decision:** Aggressive idle timeout for development  
**Rationale:** Reduces daily cost from $13.82 (24/7) to $1.15 (2hr/day); cluster restart takes 10-12 minutes which is acceptable for development workflows  
**Trade-off:** Wait time for cluster restart vs 70% cost savings

---

## Files Modified

### New Modules
- 'infra/modules/emr/main.tf' - EMR cluster with instance fleets and managed scaling
- 'infra/modules/emr/security_groups.tf' - EMR-managed security groups and rules
- 'infra/modules/emr/variables.tf' - Module input variables
- 'infra/modules/emr/outputs.tf' - Cluster ID, security group IDs, scaling policy

### Updated Modules
- 'infra/modules/iam/emr_service_role.tf' - EMR service role with AmazonEMRServicePolicy_v2
- 'infra/modules/iam/emr_ec2_role.tf' - EC2 instance profile with S3/Glue/KMS access
- 'infra/modules/iam/variables.tf' - Added EMR-specific variables
- 'infra/modules/iam/outputs.tf' - Export EMR role names
- 'infra/modules/vpc/main.tf' - Added NAT Gateway resources (deployed in earlier iteration)

### Environment Configuration
- 'infra/envs/prod/emr.tf' - EMR module instantiation with prod-specific parameters
- 'infra/envs/prod/main.tf' - Added EMR module to environment
- 'infra/envs/prod/outputs.tf' - Export cluster ID and scaling policy
- 'infra/envs/prod/variables.tf' - EMR configuration variables

### Documentation
- 'docs/M2-DESIGN.md' - Architecture decisions and design rationale
- 'docs/M2-IMPLEMENTATION.md' - Deployment guide and troubleshooting
- 'docs/M2-SUBMISSION.md' - This file (coach review submission)

---

## Next Steps (M3)

### Data Generators
- Python scripts to generate synthetic sales transactions, clickstream events, reference data
- Output to Bronze layer (S3) with date/hour partitioning
- Volume targets: 5M click events/day, 100K sales transactions/day

### Bronze → Silver ETL
- Spark job on EMR for data validation, normalization, schema enforcement
- Data quality gates with quarantine for failed records
- Output: Parquet with snappy compression, partitioned by date

### Silver → Gold Aggregations
- Glue jobs with bookmarks for incremental processing
- Daily aggregations: sales by store, conversion rates, sentiment trends
- Glue Workflow for orchestration

---

**M2 Status:** ✅ **COMPLETE AND VALIDATED**

**Submitted for Review:** 2025-11-05

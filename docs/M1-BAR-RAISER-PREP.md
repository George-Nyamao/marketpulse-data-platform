# M1 Bar Raiser Preparation

## Overview
Milestone 1 delivers the foundational data lake infrastructure: secure S3 storage with medallion architecture, Glue Data Catalog for schema management, and VPC networking for private AWS service access.

## Key Accomplishments

### Infrastructure Deployed (47 Resources)
- **VPC Foundation (23)**: VPC, 3 subnets, route tables, VPC endpoints (S3, Glue, CloudWatch, KMS, EC2)
- **S3 Data Lake (24)**: 5 buckets (raw, silver, gold, logs, artifacts) with encryption, versioning, access logging, lifecycle policies
- **Glue Catalog (2)**: Bronze and Gold databases for schema management

### Security Posture
- All S3 buckets: Public access blocked, encryption at rest (AES256), versioning enabled
- Private networking: VPC endpoints eliminate public internet exposure
- Audit trail: S3 access logging for all data buckets with 180-day retention
- Least privilege: Glue service role follows AWS best practices (in M2)

### Cost Optimization
- Lifecycle policies: Raw data → STANDARD_IA (90d) → DEEP_ARCHIVE (180d)
- VPC endpoints: ~$21/month vs ~$35/month NAT Gateway
- Estimated monthly cost: $25-30 for dev environment (3 endpoints + storage)

## Architectural Decisions Deep Dive

### Why Medallion Architecture?
Bronze-Silver-Gold pattern separates concerns: raw ingestion (Bronze), validated transformation (Silver), curated analytics (Gold). This enables independent scaling, data quality workflows, and full audit trail from source to consumption.

### Why Separate Glue Databases?
Two databases (bronze vs gold) enforce clear boundary between raw and curated layers, simplify IAM policies for data consumers who should only query gold, and prevent accidental queries against unvalidated bronze data.

### Why 180-Day Lifecycle for Raw?
Balances cost (DEEP_ARCHIVE is 95% cheaper than STANDARD) with operational access patterns where recent data (<90d) sees 80%+ of queries. 180-day threshold aligns with typical compliance retention and supports quarterly trend analysis.

### Why S3 Access Logging?
Provides security audit trail for compliance (SOC2/GDPR), enables anomaly detection (e.g., unusual access patterns), supports cost attribution analysis, and has negligible performance impact (<1% overhead).

## Testing & Validation

### Proof Artifacts
```bash
# Verify S3 bucket configurations
aws s3api get-bucket-versioning --bucket marketpulse-moraran-dev-raw
aws s3api get-bucket-encryption --bucket marketpulse-moraran-dev-silver
aws s3api get-bucket-logging --bucket marketpulse-moraran-dev-gold
aws s3api get-bucket-lifecycle-configuration --bucket marketpulse-moraran-dev-raw

# Verify Glue databases
aws glue get-database --name marketpulse_dev_bronze
aws glue get-database --name marketpulse_dev_gold

# Verify VPC endpoints
aws ec2 describe-vpc-endpoints --filters "Name=vpc-id,Values=$(terraform output -raw vpc_id)"
```

### Expected Questions & Answers

**Q: Why not use KMS encryption in M1?**
A: KMS adds $1/month per key plus $0.03/10k requests. For dev environment with <10k monthly operations, SSE-S3 (AES256) provides adequate encryption at rest without operational complexity of key rotation. Production will use KMS for regulatory compliance.

**Q: How do you prevent data loss in S3?**
A: Three layers: (1) Versioning enabled on all data buckets, (2) Noncurrent version expiration after 90-180 days, (3) Lifecycle policies transition to DEEP_ARCHIVE rather than delete, providing 180-day recovery window.

**Q: What's the blast radius of a compromised EMR cluster?**
A: Limited by IAM policies (M2) scoping EMR role to specific S3 prefixes and Glue databases. VPC endpoints prevent internet exfiltration. S3 access logging provides audit trail for forensics.

**Q: How does this architecture scale?**
A: Horizontally: Add buckets/databases per tenant or region. Vertically: S3 auto-scales to any throughput. Partition pruning in Athena reduces scan costs linearly with time-range queries. EMR (M2) scales compute independently from storage.

**Q: What's your DR strategy?**
A: S3 Cross-Region Replication (not yet implemented) provides RPO <15 min. Versioning provides point-in-time recovery. Terraform state in S3 backend enables infrastructure rebuild in <10 minutes.

## Demonstration Flow

1. **Show Terraform state**: 'terraform output' to display all deployed resources
2. **Navigate S3 console**: Show bucket structure, encryption, versioning, logging, lifecycle
3. **Navigate Glue console**: Show bronze/gold databases
4. **Navigate VPC console**: Show endpoints and route tables
5. **Run AWS CLI commands**: Execute proof artifacts to validate configurations
6. **Show cost estimates**: CloudWatch billing or Cost Explorer for current month

## Known Limitations & Future Work

### Limitations
- Dev environment only (no staging/prod)
- No KMS encryption (SSE-S3 instead)
- No cross-region replication
- No data in buckets yet (M3 ingestion)

### Future Milestones
- M2: EMR cluster for Spark processing
- M3: Data ingestion pipelines
- M4: Athena queries and BI dashboards
- M5: CI/CD automation

## Time Investment
- Research & design: 4 hours
- Implementation: 6 hours
- Testing & documentation: 3 hours
- **Total: 13 hours**

## Success Criteria Met
✅ All S3 buckets deployed with security controls
✅ Glue Data Catalog configured
✅ VPC networking with private endpoints
✅ Cost-optimized lifecycle policies
✅ Comprehensive audit logging
✅ Infrastructure as Code (Terraform)
✅ Documentation complete


# M1 Submission - Storage & Catalog Infrastructure

## Overview
Complete foundational data lake infrastructure with medallion architecture (Bronze-Silver-Gold), secure S3 storage, Glue Data Catalog, VPC networking, and IAM roles.

## Infrastructure Summary

### Total Resources Deployed: 56

#### VPC Foundation (23 resources)
- 1 VPC with flow logs
- 4 Subnets (2 private, 2 public)
- 2 Route tables + 4 associations
- 1 Internet Gateway
- 6 VPC Endpoints (S3, Glue, Logs, KMS, EC2, STS)
- 1 Security Group
- IAM role for VPC flow logs

#### S3 Data Lake (27 resources)
**Buckets:**
- marketpulse-moraran-dev-raw (Bronze layer)
- marketpulse-moraran-dev-silver (Silver layer)
- marketpulse-moraran-dev-gold (Gold layer)
- marketpulse-moraran-dev-logs (Centralized logging)
- marketpulse-moraran-dev-artifacts (Code artifacts)

**Security Configurations:**
- Block Public Access: ON (all buckets)
- Default Encryption: SSE-S3 (AES256)
- Versioning: ON (raw, silver, gold, artifacts)
- Access Logging: 4 data buckets → logs bucket

**Lifecycle Policies:**
- Raw: STANDARD → STANDARD_IA @ 90d → DEEP_ARCHIVE @ 180d
- Artifacts: STANDARD → STANDARD_IA @ 90d
- Logs: Expire @ 180d

#### Glue Data Catalog (3 resources)
**Pattern Chosen: Layered Databases (Pattern B)**
- marketpulse_dev_bronze → s3://marketpulse-moraran-dev-raw/
- marketpulse_dev_silver → s3://marketpulse-moraran-dev-silver/
- marketpulse_dev_gold → s3://marketpulse-moraran-dev-gold/

#### IAM (3 resources)
- Glue service role: marketpulse-dev-glue-service-role
- Inline least-privilege policy (read raw, read/write silver+gold, write logs)
- Attached AWS managed policy: AWSGlueServiceRole

---

## Terraform Artifacts

### Apply Output
Apply complete! Resources: 56 added, 0 changed, 0 destroyed.

Outputs:
- artifacts_bucket = marketpulse-moraran-dev-artifacts
- bronze_database = marketpulse_dev_bronze
- glue_service_role_arn = arn:aws:iam::509256337340:role/marketpulse-dev-glue-service-role
- gold_bucket = marketpulse-moraran-dev-gold
- silver_bucket = marketpulse-moraran-dev-silver
- vpc_id = vpc-0dea028fa045e6f28

---

## S3 Configuration Proof

### Versioning: Enabled
### Encryption: AES256
### Access Logging: Enabled to logs bucket with prefix
### Lifecycle: Raw bucket transitions to IA (90d) then Deep Archive (180d)

---

## Naming & Partition Documentation

### Bucket Structure
marketpulse-{suffix}-{env}-{layer}

### Partition Scheme

**Bronze (Raw):**
s3://marketpulse-moraran-dev-raw/
  stocks/year=YYYY/month=MM/day=DD/hour=HH/
  news/year=YYYY/month=MM/day=DD/hour=HH/
  sentiment/year=YYYY/month=MM/day=DD/hour=HH/

**Silver (Validated):**
s3://marketpulse-moraran-dev-silver/
  stocks/year=YYYY/month=MM/
  news/year=YYYY/month=MM/
  market_events/year=YYYY/month=MM/

**Gold (Curated):**
s3://marketpulse-moraran-dev-gold/
  daily_summaries/year=YYYY/month=MM/
  sentiment_trends/year=YYYY/
  correlations/snapshot_date=YYYY-MM-DD/

**Rationale:**
- Hourly partitions in Bronze for high-frequency ingestion
- Monthly partitions in Silver balance query performance with partition overhead
- Yearly/snapshot partitions in Gold for aggregated analytics
- Date-based partitioning enables Athena partition pruning (90% cost reduction)

---

## Architectural Decisions

### 1. Crawler vs Schema-on-Write
**Decision:** Schema-on-write for Silver/Gold; crawlers optional for Bronze discovery.

**Rationale:** Silver and Gold layers require deterministic schemas for stable consumption by BI tools. Bronze can use crawlers for initial discovery, but production ETL jobs define explicit schemas during Silver transformation to ensure data quality and type safety.

### 2. Partition Keys
**Decision:** Date-based partitioning (year/month/day/hour hierarchy).

**Rationale:** 
- Query optimization: Time-range filters are most common in analytics workloads
- COPY performance: Redshift COPY can efficiently load specific date partitions
- Cost control: Athena partition pruning reduces scan costs by 90%+
- Operational simplicity: Date partitions align with data retention policies

### 3. Lifecycle Retention
**Decision:** Raw 180d to Deep Archive, Logs 180d retention, Artifacts 90d to IA.

**Rationale:**
- Cost: Deep Archive is 95% cheaper than Standard
- Compliance: 180-day retention meets typical audit requirements
- Access patterns: 80%+ of queries target data less than 90 days old
- Recovery: 180-day window provides adequate disaster recovery capability

---

## Bar Raiser Preparation

### Schema Drift in Bronze to Silver
**Challenge:** Bronze layer may receive JSON with optional/evolving fields.

**Strategy:**
1. Bronze: Store raw JSON as-is with ingest_date partition
2. Silver ETL: Use Spark schema evolution with mergeSchema=true
3. Missing columns: Fill with nulls using coalesce
4. New columns: Add to Silver schema with nullable=true
5. Type conflicts: Reject row and log to DLQ in logs bucket
6. Schema registry: Maintain schema versions in Glue Catalog

### Small Files Compaction
**Challenge:** Hourly Bronze ingestion creates many small files, degrading query performance.

**Strategy:**
1. Daily compaction job: Coalesce hourly partitions into daily
2. Target size: 128-512 MB parquet files (optimal for Spark/Athena)
3. Schedule: Run at 2 AM daily for previous day data
4. Retention: Keep hourly partitions for 7 days after compaction
5. Monitoring: Track file count and avg size in CloudWatch

**Implementation:**
- EMR step job runs daily
- Reads hourly partitions for date D-1
- Writes compacted daily partition
- Deletes source hourly partitions after success

### Redshift Preliminary Design
**Table:** fct_sales

**Distribution Key:** store_id
- Rationale: Most queries filter or join on store_id
- Co-locates related sales data on same node
- Minimizes shuffle for store-level aggregations

**Sort Key:** COMPOUND (dt, store_id)
- Rationale: Time-series queries filter by date range first
- Then drill into specific stores
- Compound key optimizes for this sequential filter pattern
- Alternative: INTERLEAVED (dt, store_id) if query patterns vary

**Query Mix Consideration:**
- If 80%+ queries filter by date: COMPOUND sort key
- If queries equally filter by date OR store: INTERLEAVED sort key
- Monitor query patterns in production and adjust

---

## Cost Estimate

**Monthly costs for dev environment:**
- VPC Endpoints (6): $21/month ($7/endpoint × 3 interface)
- S3 Storage (estimate 100GB): $2.30/month
- S3 Requests: $0.50/month
- VPC Flow Logs: $1/month
- Total: ~$25/month

**Cost optimizations:**
- Deep Archive saves 95% storage costs for old data
- VPC endpoints eliminate NAT Gateway ($35/month saved)
- Lifecycle policies automatically tier storage

---

## Documentation References
- Naming Conventions: docs/naming-conventions.md
- Architectural Decisions: docs/M1-DECISIONS.md
- Bar Raiser Prep: docs/M1-BAR-RAISER-PREP.md
- Validation Proof: docs/M1-VALIDATION-PROOF-FINAL.txt
- Session Notes: docs/session-20251101-part2.md

---

## Success Criteria Met

- S3 buckets with all security controls
- Glue Data Catalog configured (3 databases)
- VPC networking with private endpoints
- IAM role with least-privilege policy
- Cost-optimized lifecycle policies
- Comprehensive audit logging
- Infrastructure as Code (Terraform)
- Complete documentation

**M1 Status: ✅ COMPLETE**

Ready for M2 (EMR Cluster)

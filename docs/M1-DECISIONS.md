# M1 Architectural Decisions

## Decision Log

### 1. Medallion Architecture (Bronze-Silver-Gold)
**Decision**: Implemented three-tier data lakehouse pattern with Raw (Bronze), Silver, and Gold buckets.
**Rationale**: Separates raw ingestion from curated analytics, enabling independent scaling and data quality workflows while maintaining full audit trail from source to consumption.

### 2. S3 Storage Classes & Lifecycle Management
**Decision**: Tiered storage with STANDARD → STANDARD_IA (90d) → DEEP_ARCHIVE (180d) for raw data; artifacts transition to IA at 90 days; logs retained for 180 days.
**Rationale**: Balances cost optimization (Deep Archive is 95% cheaper than Standard) with operational access patterns where recent data (<90d) sees 80%+ of queries while maintaining compliance retention.

### 3. S3 Access Logging to Centralized Logs Bucket
**Decision**: Enabled server access logging for all data buckets (raw, silver, gold, artifacts) with prefixed paths in logs bucket.
**Rationale**: Provides security audit trail for compliance (SOC2/GDPR), enables anomaly detection, and supports cost attribution analysis without performance impact on data operations.

### 4. AWS Glue Data Catalog with Separate Bronze/Gold Databases
**Decision**: Created two Glue databases rather than single database with prefixed tables.
**Rationale**: Enforces clear boundary between raw ingestion layer and curated analytics layer, simplifies IAM policies for data consumers who should only query gold layer, and prevents accidental queries against unvalidated bronze data.

### 5. VPC Endpoints for S3, Glue, CloudWatch
**Decision**: Deployed gateway endpoint (S3) and interface endpoints (Glue, Logs) rather than NAT Gateway.
**Rationale**: Eliminates ~$35/month NAT Gateway costs while maintaining private connectivity; S3 gateway endpoint has no data transfer charges; interface endpoints cost $7/month each but avoid NAT data processing fees.

### 6. KMS Encryption Deferred, AES256 Default
**Decision**: Used S3-managed encryption (AES256) instead of customer-managed KMS keys in M1.
**Rationale**: KMS adds $1/month per key plus $0.03/10k requests; for dev environment with <10k monthly operations, SSE-S3 provides adequate encryption at rest without operational complexity of key rotation and IAM key policies. Production will use KMS.

### 7. Bucket Versioning Enabled for Data Buckets
**Decision**: Enabled versioning on raw, silver, gold, and artifacts buckets.
**Rationale**: Protects against accidental deletions and overwrites during development; supports data lineage tracking; enables rollback for artifacts deployments. Noncurrent versions expire after 90-180 days to control costs.

### 8. Logs Bucket 180-Day Retention
**Decision**: Extended log retention from default 30 days to 180 days for S3 access logs and application logs.
**Rationale**: Aligns with typical compliance requirements (GDPR 6-month retention); supports retrospective security investigations; 180-day S3 logs cost ~$0.50/month in STANDARD_IA versus immediate deletion providing negligible savings with significant risk.


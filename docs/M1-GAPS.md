# M1 Gaps to Fix

## S3 Configuration Updates

### 1. Add Access Logging
**File:** infra/modules/s3/main.tf

Add to each data bucket (raw, silver, gold, artifacts):
- Target bucket: logs bucket
- Prefix: access-logs/{bucket-name}/

### 2. Update Lifecycle Policies

**raw bucket:**
- Current: 90d → STANDARD_IA
- Add: 180d → GLACIER_DEEP_ARCHIVE

**logs bucket:**
- Current: 30d expiry
- Change to: 180d expiry

**artifacts bucket:**
- Add: 90d → STANDARD_IA

## Documentation Updates

### 3. Enhance naming-conventions.md
Add detailed partition schemes:
- Bronze: s3://raw/<domain>/ingest_date=YYYY-MM-DD/hour=HH/
- Silver: s3://silver/<domain>/ingest_date=YYYY-MM-DD/
- Gold: s3://gold/<dataset>/dt=YYYY-MM-DD/

Add table naming:
- br_sales_raw, br_clicks_raw (bronze)
- sl_sales, sl_clicks (silver)
- g_sales_by_store, g_conversion_rates (gold)

### 4. Write Decision Note
File: docs/M1-DECISIONS.md
Topics to cover (5-8 sentences):
- Why schema-on-write for Silver/Gold (vs crawlers)
- Partition key choices (query patterns)
- Lifecycle retention (cost vs compliance)

### 5. Bar-Raiser Prep
File: docs/M1-BAR-RAISER-PREP.md
Answer:
- Schema drift handling in clicks domain
- Small files compaction strategy
- Redshift dist/sort key preliminary choices

## Proof Artifacts for Coach

### 6. Gather Evidence
Commands to run:
- terraform output (capture all)
- aws s3api get-bucket-versioning --bucket marketpulse-moraran-dev-raw
- aws s3api get-bucket-encryption --bucket marketpulse-moraran-dev-raw
- aws s3api get-public-access-block --bucket marketpulse-moraran-dev-raw
- aws glue get-databases --profile marketpulse

Compile into: docs/M1-PROOF.md

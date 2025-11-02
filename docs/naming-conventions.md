# MarketPulse Naming Conventions

## S3 Buckets

**Pattern:** '{project}-{identifier}-{environment}-{purpose}'

### Examples:
- 'marketpulse-moraran-dev-raw'
- 'marketpulse-moraran-dev-silver'
- 'marketpulse-moraran-dev-gold'
- 'marketpulse-moraran-dev-logs'
- 'marketpulse-moraran-dev-artifacts'

**Rationale:**
- '{project}': Namespace for all resources
- '{identifier}': Ensures global uniqueness (user-specific)
- '{environment}': dev/stg/prod isolation
- '{purpose}': Functional layer (raw/silver/gold/logs/artifacts)

### Scaling Across Environments:
```
Dev:  marketpulse-moraran-dev-raw
Stg:  marketpulse-moraran-stg-raw
Prod: marketpulse-moraran-prod-raw
```

---

## Glue Databases

**Pattern:** '{project}_{environment}_{layer}'

### Examples:
- 'marketpulse_dev_bronze'
- 'marketpulse_dev_silver'
- 'marketpulse_dev_gold'

**Rationale:**
- Underscores (not hyphens) per Glue naming requirements
- Clear layer designation (bronze/silver/gold)
- Environment prefix for isolation

---

## Glue Tables (Future)

**Pattern:** '{domain}_{detail}'

### Examples:
- 'sales_transactions'
- 'clicks_raw'
- 'dim_stores'
- 'fct_sales_daily'

---

## IAM Roles (M2)

**Pattern:** '{project}-{environment}-{service}-role'

### Examples:
- 'marketpulse-dev-emr-service-role'
- 'marketpulse-dev-emr-ec2-role'
- 'marketpulse-dev-glue-job-role'

---

## Tags (Applied to All Resources)

**Standard Tags:**
- 'Project: MarketPulse'
- 'Environment: dev|stg|prod'
- 'ManagedBy: Terraform'
- 'Owner: moraran'

**Resource-Specific Tags:**
- S3: 'Layer', 'DataQuality', 'Purpose'
- Glue: 'Layer'
- VPC: 'Tier' (Public/Private)

---

## File Naming in S3

### Raw Data:
```
s3://marketpulse-moraran-dev-raw/
  sales/
    ingest_date=2024-11-01/
      part-00000.parquet
  clicks/
    ingest_date=2024-11-01/
      hour=00/
        part-00000.parquet
```

### Silver Data:
```
s3://marketpulse-moraran-dev-silver/
  sales/
    year=2024/month=11/day=01/
      part-00000.snappy.parquet
```

### Gold Data:
```
s3://marketpulse-moraran-dev-gold/
  sales_by_store/
    year=2024/month=11/
      part-00000.snappy.parquet
```

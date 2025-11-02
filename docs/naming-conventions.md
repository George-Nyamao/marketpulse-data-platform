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

## S3 Partitioning Strategy

### Raw Bucket Partitions
```
s3://marketpulse-{suffix}-{env}-raw/
├── stocks/
│   └── year=YYYY/month=MM/day=DD/
│       └── {symbol}_{timestamp}.json
├── news/
│   └── year=YYYY/month=MM/day=DD/
│       └── {source}_{timestamp}.json
└── sentiment/
    └── year=YYYY/month=MM/day=DD/
        └── {symbol}_{timestamp}.json
```

**Rationale**: Date-based partitioning enables efficient Athena queries with partition pruning, reducing scan costs by up to 90% when filtering by date ranges.

### Silver Bucket Partitions
```
s3://marketpulse-{suffix}-{env}-silver/
├── stocks/
│   └── year=YYYY/month=MM/
│       └── {symbol}.parquet
├── news/
│   └── year=YYYY/month=MM/
│       └── sentiment_scores.parquet
└── market_events/
    └── year=YYYY/month=MM/
        └── events.parquet
```

**Rationale**: Monthly partitions balance query performance with partition overhead. Parquet format provides columnar storage for analytics workloads.

### Gold Bucket Partitions
```
s3://marketpulse-{suffix}-{env}-gold/
├── daily_summaries/
│   └── year=YYYY/
│       └── month=MM/daily_summary.parquet
├── sentiment_trends/
│   └── year=YYYY/trends.parquet
└── correlations/
    └── snapshot_date=YYYY-MM-DD/correlations.parquet
```

**Rationale**: Yearly/snapshot partitions for aggregated data reduce partition count while maintaining query efficiency for analytical queries.

### Logs Bucket Structure
```
s3://marketpulse-{suffix}-{env}-logs/
├── s3-access-logs/
│   ├── raw/
│   ├── silver/
│   ├── gold/
│   └── artifacts/
├── emr-logs/
│   └── cluster-{id}/
└── glue-logs/
    └── job-{name}/
```

**Rationale**: Segregated log paths enable targeted lifecycle policies and simplified audit trail analysis.

### Artifacts Bucket Structure
```
s3://marketpulse-{suffix}-{env}-artifacts/
├── jars/
│   └── {version}/
├── wheels/
│   └── {version}/
├── scripts/
│   ├── bootstrap/
│   └── steps/
└── configs/
    └── {service}/
```

**Rationale**: Version-based organization supports reproducible deployments and rollback capabilities.


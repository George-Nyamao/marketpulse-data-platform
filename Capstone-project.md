# Capstone: AWS Data Platform (Glue • EMR • Redshift • Terraform • Python)

## Why this project

You’ll build an end‑to‑end production‑style data platform from scratch, exercising exactly what JPMC will probe: Python coding, AWS Glue, EMR clusters, Redshift, and Terraform-first infrastructure. I’ll act as your coach/reviewer: I’ll give constraints, acceptance criteria, and review checklists. You will design and implement—no copy/paste code.

---

## Business scenario

**MarketPulse**: a fictional fintech analytics product that ingests point‑of‑sale transactions (batch) and clickstream events (streaming‑ish), curates a lakehouse on S3, computes daily metrics, and serves analytics via Redshift. Future extensions add ML features and incremental/CDC patterns.

**Data domains (synthetic):**

* **sales**: transaction_id, user_id, store_id, ts, items[], payment_type, amount, currency
* **clicks**: user_id, session_id, ts, page, referrer, utm_*
* **reference**: stores, users (slowly changing dims)

You will generate data with Python producers (local or on EMR) to avoid external dependencies.

---

## Target architecture (high level)

* **Ingress** → land raw JSON/CSV into `s3://marketpulse-<env>-raw/<domain>/ingest_date=YYYY-MM-DD/` (hour partitions for clicks)
* **Catalog/Governance** → AWS Glue Data Catalog, crawlers or schema-on-write via Spark/Glue ETL
* **Processing** → Spark on EMR for heavy batch; Glue Jobs for curated transforms & job bookmarks
* **Storage** → Bronze (raw), Silver (validated/normalized Parquet), Gold (aggregations & dimensional models)
* **Serve** → Redshift (serverless or RA3) external schema + COPY into internal tables for high-QPS marts
* **Orchestration/Observability** → Glue Workflows/Triggers or EMR Steps, CloudWatch metrics/logs
* **IaC** → Terraform modules for IAM, S3, Glue, EMR, Redshift, networking, and backends

Constraints: partition by date/hour; schema evolution tolerated on `clicks`; data quality gates block bad loads; cost-aware defaults (spot where safe, autoscaling EMR, compression ZSTD/Snappy).

---

## Tech constraints (what you must demonstrate)

* **Terraform from scratch**: remote state (S3 + DynamoDB lock), workspaces per env (dev/stg/prod)
* **EMR**: cluster provisioning (core+task groups), autoscaling policy, bootstrap actions (Py/Java), submit Spark steps
* **Glue**: jobs with bookmarks, crawlers or schema-on-write, job metrics, retry strategy
* **Redshift**: parameter group, WLM/queues (if non-serverless), dist/sort keys rationale, COPY & UNLOAD patterns, external schema
* **Python**: producers, validators, and Spark job code structure (packaged wheel is a plus)
* **Security**: least-privilege IAM roles for jobs, S3 bucket policies, KMS at rest, TLS in transit

---

## Milestones & acceptance criteria

**M0 – Foundations (Terraform backend & networking)**

* Deliverables: `main.tf`, `backend.tf`, `providers.tf`, `variables.tf`, `outputs.tf`; VPC, subnets, endpoints for S3/Glue, NAT (optional), tags
* Accept: `terraform init/plan` succeeds; remote state created; diagram & README with CIDR plan

**M1 – Storage & Catalog**

* Deliverables: S3 buckets (`raw`, `silver`, `gold`, `logs`, `artifacts`), bucket policies, Glue catalog DBs, optional crawlers
* Accept: versioning on, default encryption, block public access; Glue DBs visible; naming convention doc

**M2 – EMR cluster**

* Deliverables: EMR cluster module (instance fleets or EMR Serverless optional), autoscaling, bootstrap, log delivery to S3
* Accept: cluster starts/stops via Terraform; sample Spark step runs `spark-submit --class org.apache.spark.examples.SparkPi`

**M3 – Python data generators (local or EMR)**

* Deliverables: CLI tools to emit `sales` (hourly batch) & `clicks` (near-real-time micro-batches to S3)
* Accept: folder layout `domain=/<date>/<hour>/file.parquet`; volume ≥ 5M click events/day in dev; reproducible seeds

**M4 – Bronze→Silver ETL (Spark on EMR)**

* Deliverables: Spark job(s) that validate, normalize, and write Parquet with partitioning & compaction; data quality rules (pydantic/Great Expectations-like checks)
* Accept: failed records quarantined; metrics logged; Glue tables registered; schema evolution path documented

**M5 – Silver→Gold ETL (Glue Jobs)**

* Deliverables: Glue job with bookmarks to compute daily summaries (sales_by_store, conversion_rates), plus Glue Workflow/Triggers
* Accept: idempotent re-runs; partition overwrite safe; bookmarks skip already processed partitions

**M6 – Redshift serving layer**

* Deliverables: Redshift (serverless or RA3) via Terraform; external schema to `gold`; COPY into internal marts (e.g., `fct_sales`, `dim_store`, `fct_clicks_agg`)
* Accept: dist/sort key rationale; BI-style queries return in < 3s on sample volumes; UNLOAD back to S3 tested

**M7 – Ops & FinOps**

* Deliverables: Cost guardrails (S3 lifecycle, EMR auto-terminate, compression), CloudWatch alarms/dashboards, runbooks
* Accept: clean teardown, documented RPO/RTO, run cost estimate & savings notes

---

## Code & repo expectations

```
marketpulse/
  infra/
    envs/{dev,stg,prod}/
    modules/{vpc,s3,iam,glue,emr,redshift}
  jobs/
    spark/{bronze_to_silver, utils, dq}
    glue/{silver_to_gold}
  data_gen/
    sales_gen.py
    clicks_gen.py
  analytics/
    redshift/sql/
  docs/
    architecture.drawio
    decisions/ADR-*.md
  Makefile (or taskfile)
  README.md
```

---

## Review protocol (how we’ll work)

* For each milestone, you share: 1) a short design note (500–800 words), 2) `terraform plan` output (redacted if needed), 3) key directory listings, 4) sample logs/metrics, 5) screenshots of AWS consoles **or** CLI outputs.
* I’ll respond with a code/design review checklist and challenge questions (like a bar-raiser would).

---

## Interview-practice hooks (what to be ready to explain)

* EMR vs Glue trade-offs; when to use each
* Redshift dist/sort keys and external vs internal tables
* Schema evolution and job bookmarks
* Autoscaling policies and spot strategy on EMR
* Terraform module boundaries and state layout

---

## Sprint 0 checklist (do this first)

1. Install/confirm: AWS CLI, Terraform, Python 3.10+, Java 11, Docker (optional)
2. Create an AWS account or sandbox; set up an IAM admin profile for bootstrap only
3. Decide regions & CIDR ranges; pick bucket name prefix `marketpulse-<acct>-<env>`
4. Create an **empty** Git repo with the structure above

**Acceptance for Sprint 0:** Share your chosen region, CIDR, bucket prefix, and a `tree -L 2` of your repo.

---

## Milestone 0 assignment (start here)

**Goal:** Provision Terraform backend + providers + VPC skeleton.

**Requirements:**

* Remote state: S3 bucket `tfstate-<acct>-global` (+ DynamoDB table `tf-lock`)
* Workspaces: `dev`, `stg`, `prod`
* VPC with 2 AZs, 2 public + 2 private subnets, VPC endpoints for S3 & Glue
* Tags: `app=marketpulse`, `env`, `owner`, `cost-center`

**Artifacts to submit for review:**

* Output of `terraform workspace list` and `terraform plan` (dev)
* VPC, subnets, and endpoints IDs (redact acct IDs)
* A short note explaining your CIDR and endpoint choices

When you’re ready, paste the artifacts here and I’ll do a reviewer pass and push you to the next milestone.

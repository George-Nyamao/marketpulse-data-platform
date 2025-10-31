# MarketPulse Data Platform

End-to-end AWS data platform demonstrating production-grade lakehouse architecture.

## Architecture

- **Ingestion**: Batch (sales) and streaming (clickstreams) to S3
- **Processing**: Spark on EMR + AWS Glue jobs
- **Storage**: Bronze/Silver/Gold medallion architecture
- **Serving**: Redshift with external tables
- **IaC**: 100% Terraform-managed infrastructure

## Tech Stack

- **Cloud**: AWS (us-east-2)
- **Compute**: EMR, Glue
- **Storage**: S3, Redshift
- **Orchestration**: Glue Workflows
- **IaC**: Terraform
- **Languages**: Python, SQL

## Project Status

🚧 **In Progress** - Currently completing Milestone 0 (VPC & Terraform backend)

## Repository Structure
├── infra/ # Terraform infrastructure
│ ├── envs/ # Environment configs (dev/stg/prod)
│ └── modules/ # Reusable Terraform modules
├── jobs/ # Spark and Glue job code
├── data_gen/ # Synthetic data generators
└── analytics/ # SQL queries and models

## Milestones

- [x] Sprint 0: Project setup and planning
- [ ] M0: Terraform backend + VPC
- [ ] M1: S3 buckets + Glue catalog
- [ ] M2: EMR cluster provisioning
- [ ] M3: Data generators
- [ ] M4: Bronze→Silver ETL
- [ ] M5: Silver→Gold aggregations
- [ ] M6: Redshift serving layer
- [ ] M7: Observability + FinOps

---

**Author**: Morara  
**Purpose**: AWS Data Engineering Capstone

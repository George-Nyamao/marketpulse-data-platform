# MarketPulse Data Platform Gemini Guide

This document provides a comprehensive guide for interacting with the MarketPulse Data Platform project.

## Project Overview

This project is an end-to-end AWS data platform that demonstrates a production-grade lakehouse architecture. It uses Terraform to manage the entire infrastructure as code.

**Key Technologies:**

*   **Cloud:** AWS (us-east-2)
*   **Compute:** EMR, Glue
*   **Storage:** S3, Redshift
*   **Orchestration:** Glue Workflows
*   **IaC:** Terraform
*   **Languages:** Python, SQL

**Architecture:**

*   **Ingestion:** Batch (sales) and streaming (clickstreams) data is ingested into an S3 bronze layer.
*   **Processing:** Spark on EMR and AWS Glue jobs process the data from the bronze layer and store it in a silver layer (validated and normalized data) and a gold layer (business-ready aggregations and models).
*   **Storage:** The data is stored in a medallion architecture (bronze, silver, and gold) in S3.
*   **Serving:** The gold layer is served to end-users via Redshift with external tables.

## Building and Running

The infrastructure is managed with Terraform. The following commands are used to build and deploy the platform:

1.  **Initialize Terraform:**
    ```bash
    cd infra/envs/dev
    terraform init
    ```
2.  **Plan changes:**
    ```bash
    terraform plan
    ```
3.  **Apply changes:**
    ```bash
    terraform apply
    ```

**Note:** The AWS profile `marketpulse` is used for all AWS commands.

## Development Conventions

*   **Infrastructure as Code:** All infrastructure is managed with Terraform.
*   **Modular Design:** The Terraform code is organized into reusable modules for different services (e.g., VPC, S3, Glue).
*   **Environment Separation:** The infrastructure is deployed to different environments (dev, stg, prod) using Terraform workspaces.
*   **Medallion Architecture:** The data is stored in a bronze, silver, and gold medallion architecture.
*   **Data Quality:** The data is validated and normalized before it is stored in the silver layer.
*   **Business-Ready Data:** The gold layer contains business-ready aggregations and models.

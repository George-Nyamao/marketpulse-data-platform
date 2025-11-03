# M2 Design - EMR Cluster on EC2

## Objective
Deploy production-grade EMR 6.x cluster in private subnets with managed scaling, Spot instances, and complete observability.

## Design Decisions

### 1. EMR Release & Applications
- **Release**: EMR 6.15.0 (latest stable 6.x)
- **Applications**: Hadoop 3.3.3, Spark 3.4.1
- **Rationale**: Spark 3.4.x provides performance improvements (Adaptive Query Execution, Dynamic Partition Pruning) and better Parquet handling for our medallion architecture workloads.

### 2. Network Configuration
- **Subnets**: Private only (subnet-0fe2aedcc10ad20e6, subnet-099a96b76f471aad8)
- **AZs**: us-east-2a, us-east-2b
- **No Public IPs**: All nodes private, access via Session Manager (future)
- **VPC Endpoints**: S3, Glue, STS, EC2, Logs, KMS (already deployed)
- **Rationale**: Private subnet deployment eliminates internet exposure; VPC endpoints enable AWS service access without NAT Gateway costs.

### 3. Instance Fleet Configuration

**Master Node:**
- Type: m5.xlarge (4 vCPU, 16 GB RAM)
- Purchase: On-Demand (cluster stability)
- Count: 1

**Core Nodes:**
- Fleet: m5.xlarge, m5.2xlarge
- Purchase: On-Demand
- Count: 2 (baseline HDFS capacity)
- Rationale: On-Demand cores ensure HDFS data availability

**Task Nodes (Spot):**
- Fleet: m5.xlarge, r5.xlarge, c5.xlarge (capacity diversification)
- Purchase: Spot (up to 70% savings)
- Count: 0-8 (managed scaling)
- Allocation: Capacity-optimized (minimize interruptions)
- Rationale: Mix of compute (c5), memory (r5), and general (m5) instances across AZs reduces interruption probability to <5%

### 4. Managed Scaling
- **Strategy**: Custom policy
- **Min Units**: 2 (master + 2 cores)
- **Max Units**: 10 (master + 2 cores + 8 tasks)
- **Scale-Up**: When YARN pending memory >75% for 5 min
- **Scale-Down**: When YARN available >50% for 10 min
- **Cooldown**: 300 seconds
- **Rationale**: Conservative scaling prevents thrashing; 5:1 max:min ratio handles burst workloads while controlling costs

### 5. Auto-Termination
- **Idle Timeout**: 1800 seconds (30 minutes)
- **Rationale**: Dev cluster auto-terminates after 30 min idle, saving ~$20/day vs always-on

### 6. Logging Configuration

**S3 Logs:**
- Path: s3://marketpulse-moraran-dev-logs/emr/
- Retention: 180 days (inherited from bucket lifecycle)
- Contents: Cluster logs, step logs, Hadoop/Spark logs

**CloudWatch Logs:**
- Log Group: /aws/emr/marketpulse-dev
- Retention: 7 days (dev), 30 days (prod)
- Streams: Container logs, application logs
- Rationale: S3 for long-term audit/debugging; CloudWatch for real-time monitoring and alerting

### 7. Security Configuration

**Network:**
- Security Groups: Managed by EMR (intra-cluster + VPCE access)
- No internet: All AWS API calls via VPC endpoints
- S3 access: Via S3 gateway endpoint (no data transfer charges)

**IAM:**
- EMR Service Role: Read/write project S3 buckets, decrypt KMS key
- EC2 Instance Profile: Same permissions + CloudWatch Logs write
- Principle: Least-privilege, scoped to project resources only

**Encryption:**
- At-rest: S3 SSE-KMS (using CMK: d3667334-fdf4-4add-953a-c89e0851e6ad)
- In-transit: TLS 1.2+ for all cluster communication
- EBS: Encrypted with default AWS-managed key

### 8. Bootstrap & Artifacts
- **Artifacts Path**: s3://marketpulse-moraran-dev-artifacts/emr/
- **Bootstrap Script**: Install Python packages (pandas, boto3, pyarrow) from wheels
- **No Internet**: All dependencies pre-staged in artifacts bucket
- **Rationale**: Reproducible builds, no external dependency on PyPI/Maven

## Architecture Diagram

```
┌─────────────────────────────────────────────────────────────┐
│  VPC (10.0.0.0/16)                                          │
│  ┌────────────────────────────┐  ┌──────────────────────┐  │
│  │ Private Subnet (us-east-2a)│  │ Private Subnet (2b)  │  │
│  │ 10.0.1.0/24                │  │ 10.0.2.0/24          │  │
│  │                            │  │                      │  │
│  │  ┌──────────┐              │  │  ┌──────────┐       │  │
│  │  │  Master  │              │  │  │  Core 2  │       │  │
│  │  │ m5.xlarge│              │  │  │m5.xlarge │       │  │
│  │  └──────────┘              │  │  └──────────┘       │  │
│  │  ┌──────────┐              │  │  ┌──────────┐       │  │
│  │  │  Core 1  │              │  │  │  Task    │       │  │
│  │  │m5.xlarge │              │  │  │  (Spot)  │       │  │
│  │  └──────────┘              │  │  └──────────┘       │  │
│  └────────────────────────────┘  └──────────────────────┘  │
│                    │                      │                 │
│                    └──────────┬───────────┘                 │
│                               │                             │
│  ┌────────────────────────────┼─────────────────────────┐  │
│  │         VPC Endpoints      │                         │  │
│  │  S3 │ Glue │ Logs │ KMS │ EC2 │ STS                 │  │
│  └────────────────────────────┼─────────────────────────┘  │
└───────────────────────────────┼─────────────────────────────┘
                                │
                    ┌───────────▼──────────┐
                    │   AWS Services       │
                    │  S3, Glue, KMS, etc. │
                    └──────────────────────┘
```

## Cost Estimate

**Dev Cluster (running 8 hours/day, 20 days/month):**
- Master (m5.xlarge): $0.192/hr × 160 hr = $30.72
- Core 2× (m5.xlarge): $0.192/hr × 2 × 160 hr = $61.44
- Task avg 4× Spot (m5.xlarge @ 70% discount): $0.058/hr × 4 × 160 hr = $37.12
- **Total: ~$130/month**

**Savings strategies:**
- Auto-terminate after 30 min idle
- Spot for task nodes (70% savings)
- Turn off cluster outside working hours

## Bar Raiser Prep

### Why EMR vs Glue for Bronze→Silver?
EMR provides cost advantage for predictable batch workloads >1 hour. For our use case processing 100GB+ daily stock data, EMR cluster ($0.50/hr all-in) running 2-hour Bronze→Silver ETL costs $1/day vs Glue DPU ($0.44/DPU-hour × 10 DPUs × 2 hr = $8.80/day). Glue better for sporadic <30 min jobs. We'll use both: EMR for heavy lifting, Glue for incremental updates.

### Spot Fleet Interruption Mitigation
Three-pronged strategy: (1) Capacity-optimized allocation requests least-interrupted pools, (2) Instance type diversification (m5, r5, c5) across families reduces correlated interruptions, (3) Multi-AZ deployment (us-east-2a, 2b) ensures at least one AZ has capacity. Historical data shows <5% interruption rate with this config vs 20%+ single-type Spot. Task nodes only (not Core) means HDFS remains stable during interruptions.

### Small File Compaction Strategy
Daily compaction on EMR (not Glue) at 2 AM: Read hourly Bronze partitions (24 files/day/symbol), coalesce to target 256 MB parquet files, write to Silver daily partition, delete source. Target 256 MB balances Spark split size (128 MB default) with S3 throughput (multi-part upload efficiency). EMR chosen over Glue because: (1) predictable schedule favors reserved capacity, (2) coalesce is memory-intensive (favors m5/r5 vs Glue's fixed 16GB DPUs), (3) cluster amortizes startup cost across 100+ symbols.

### No-NAT Operability
Six VPC endpoints enable full AWS API access: (1) S3 gateway for data I/O (free), (2) Glue for catalog access, (3) STS for IAM role assumption, (4) EC2 for EMR cluster management, (5) Logs for CloudWatch streaming, (6) KMS for encryption key access. Artifacts pre-staged in S3 (Python wheels, JARs) eliminate PyPI/Maven needs. EMR bootstrap pulls from S3 via gateway endpoint. Trade-off: No direct package manager access, but reproducible builds and zero internet attack surface.


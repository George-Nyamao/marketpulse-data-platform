# Release Notes - M2: EMR Cluster

**Version:** 2.0  
**Release Date:** 2025-11-05  
**Milestone:** M2 Complete  

## 🎯 What's New

### EMR Cluster with Instance Fleets
- **EMR 6.15.0** with Spark 3.4.1 and Hadoop 3.3.3
- **Instance Fleets** (not groups) for better availability
- **Managed Scaling** from 2 to 10 InstanceFleetUnits
- **Spot Instances** with capacity-optimized allocation
- **Auto-termination** after 30 minutes idle

### Security Enhancements
- **Private subnets only** (us-east-2a, us-east-2b)
- **Zero public IP assignment**
- **9 VPC endpoints** for AWS service access (no NAT Gateway)
- **EMR-managed security groups** with least-privilege rules
- **Resource-level IAM** policies for S3/Glue/KMS access

### Cost Optimization
- **70% Spot savings** on variable workloads
- **Auto-termination** prevents runaway costs
- **VPC endpoints** save $32/month vs NAT Gateway
- **Optimized for dev usage**: $24-27/month idle, $1.15/day active

## 📊 Metrics

| Component | Value |
|-----------|-------|
| **Total Infrastructure** | 79 resources |
| **New in M2** | 13 resources |
| **Cluster Startup** | 10-12 minutes |
| **SparkPi Test** | 1m 27s (PASSED) |
| **Cost (Active)** | $0.576/hour |
| **Cost (Idle)** | $24-27/month |

## 🧪 Testing

- ✅ Cluster deployment successful
- ✅ Reaches WAITING state
- ✅ SparkPi job completes (Pi ≈ 3.141472)
- ✅ Logs written to S3
- ✅ Private subnet validation
- ✅ No public IPs assigned
- ✅ Auto-termination configured

## 🔧 Technical Details

**Cluster ID:** j-2NFAAWN9SBXND  
**Account:** 650251694598 (production)  
**Region:** us-east-2  
**Subnets:** subnet-06cc506213338bda4, subnet-089431c72fabf191d  
**Log Path:** s3://marketpulse-moraran-prod-logs/emr/  

## 📂 Files Added/Modified

- `infra/modules/emr/` - Complete EMR module
- `infra/envs/prod/emr.tf` - Production configuration
- `docs/M2-SUBMISSION.md` - Coach review submission
- Updated IAM roles and policies

## 🔄 Migration from M1

No breaking changes. M2 adds EMR capability to existing M1 infrastructure.

## 🚀 Next Steps (M3)

- Data generators (Python)
- Bronze → Silver ETL (Spark on EMR)
- Silver → Gold aggregations (Glue Jobs)

---

**Ready for production data processing workloads.** 🎯

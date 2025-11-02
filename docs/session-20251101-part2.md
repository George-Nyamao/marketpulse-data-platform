# Session Summary - 2024-11-01 (Part 2: M2 Start)

## Completed Today:
- ✅ M1 Complete: S3 buckets + Glue databases (24 resources)
- ✅ Created comprehensive naming conventions doc
- ✅ Started M2: IAM module for EMR

## Current State:
**Total Resources Deployed:**
- M0: 23 resources (VPC, endpoints, flow logs)
- M1: 24 resources (S3 buckets, Glue databases)
- **Total: 47 resources**

**M2 Progress:**
- IAM module created (infra/modules/iam/)
- Ready to apply: 3 roles + 1 instance profile

## File Structure:
'''
infra/
├── backend-bootstrap/
│   └── [Terraform state backend]
├── modules/
│   ├── vpc/          ✅ Complete
│   ├── s3/           ✅ Complete
│   ├── glue/         ✅ Complete
│   └── iam/          🚧 Ready to apply
├── envs/
    └── dev/
        ├── main.tf       (wired: vpc, s3, glue, iam)
        ├── outputs.tf
        └── ...
'''

## Key Decisions Made:
1. **IAM Strategy:**
   - Separate service role for EMR control plane
   - EC2 instance profile for worker nodes
   - Autoscaling role for managed scaling
   - Least-privilege S3 access (project buckets only)
   - Glue catalog permissions for metastore access

2. **Security:**
   - No public IP on EMR nodes (private subnets)
   - VPC endpoints for AWS service access
   - Instance profile instead of access keys

## Next Session Starts Here:

### Step 1: Apply IAM Module
'''bash
cd /mnt/c/Users/gmnya/documents/projects/terraform-proj/marketpulse-data-platform/infra/envs/dev
terraform init
terraform plan
terraform apply
'''

### Step 2: Create EMR Module
'''bash
cd ../../modules
mkdir emr
cd emr
# Create: main.tf, security_groups.tf, variables.tf, outputs.tf, bootstrap.sh
'''

### Step 3: EMR Configuration Decisions Needed:
- Instance types (m5.xlarge for master, m5.xlarge for core?)
- Core node count (2-4 for dev?)
- Task node autoscaling (min 0, max 4?)
- Release label (emr-6.15.0 or latest?)
- Applications (Spark, Hadoop, Hive, Livy?)

## Troubleshooting Notes:
- **sed issues in WSL:** Use Python for complex text manipulation
- **Lifecycle filter warnings:** S3 lifecycle rules need empty 'filter {}' block
- **Module not found:** Run 'terraform init' after adding new modules

## Quick Context Restore:
'''bash
# From project root
./restore-context.sh

# Or manually:
cd infra/envs/dev
terraform output
git log --oneline -5
cat ../../docs/progress.md
'''

## Interview Talking Points (Ready to Explain):
1. **Why separate IAM roles?**
   - Service role: EMR control plane needs different permissions than worker nodes
   - Instance profile: Nodes need S3/Glue access, not EMR API access
   - Least privilege principle

2. **Why instance profile vs access keys?**
   - No credential management/rotation needed
   - Automatic credential refresh
   - Auditable via CloudTrail (role assumption logs)

3. **S3 bucket ARN concatenation trick:**
   - 'concat(bucket_arns, [for arn in bucket_arns : "${arn}/*"])'
   - Grants both ListBucket (bucket level) and GetObject (object level)

## Cost Estimate So Far:
- VPC endpoints (Interface): ~$0.01/hr × 5 = $0.05/hr = $36/month
- S3 buckets: Storage + requests (minimal with no data yet)
- Glue catalog: Free tier (first million objects)
- **Total: <$40/month in dev before EMR**

EMR will add:
- Master node: ~$0.10/hr
- Core nodes (2×): ~$0.20/hr
- **Est: $0.30/hr = $7.20/day = $216/month if running 24/7**
- **Mitigation: Auto-terminate after inactivity, use Spot for task nodes**

---

**Last Command Executed:**
'''bash
cat >> infra/envs/dev/main.tf  # Added IAM module
cat >> infra/envs/dev/outputs.tf  # Added IAM outputs
'''

**Next Command:**
'''bash
terraform init
terraform plan
'''

# MarketPulse Quick Reference

## Project Structure
```
marketpulse-data-platform/
├── infra/
│   ├── backend-bootstrap/     # Remote state setup
│   ├── modules/
│   │   ├── vpc/              ✅ M0
│   │   ├── s3/               ✅ M1
│   │   ├── glue/             ✅ M1
│   │   ├── iam/              🚧 M2 (ready)
│   │   └── emr/              ⏳ M2 (next)
│   └── envs/dev/
├── jobs/                      ⏳ M4-M5
├── data_gen/                  ⏳ M3
├── analytics/                 ⏳ M6
└── docs/
```

## Key Resource IDs (Dev)
```
VPC:              vpc-0dea028fa045e6f28
Subnets (Priv):   subnet-0fe2aedcc10ad20e6, subnet-099a96b76f471aad8
Subnets (Pub):    subnet-07e9043c9bbd47730, subnet-0b95017b00607739e
S3 Endpoint:      vpce-0d8c69ee63bf89dc4
Glue Endpoint:    vpce-04ffd36a05bcf8108

Buckets:
- marketpulse-moraran-dev-raw
- marketpulse-moraran-dev-silver
- marketpulse-moraran-dev-gold
- marketpulse-moraran-dev-logs
- marketpulse-moraran-dev-artifacts

Glue DBs:
- marketpulse_dev_bronze
- marketpulse_dev_silver
- marketpulse_dev_gold
```

## Common Commands

### Terraform
```bash
cd infra/envs/dev

terraform init              # Initialize/update modules
terraform workspace list    # Show workspaces
terraform plan             # Preview changes
terraform apply            # Apply changes
terraform output           # Show outputs
terraform destroy          # Tear down (careful!)
```

### Git
```bash
git status
git add .
git commit -m "message"
git push
git log --oneline -5
```

### Context Restore
```bash
./restore-context.sh        # Quick status summary
cat docs/progress.md        # Milestone progress
cat docs/session-*.md       # Session summaries
```

## Milestones Checklist
- [x] M0: VPC + Terraform backend (23 resources)
- [x] M1: S3 + Glue catalog (24 resources)
- [ ] M2: EMR cluster (IAM ready, cluster pending)
- [ ] M3: Data generators
- [ ] M4: Bronze→Silver ETL
- [ ] M5: Silver→Gold ETL
- [ ] M6: Redshift serving layer
- [ ] M7: Ops & FinOps

## Current Task
**Apply IAM module for EMR, then create EMR cluster module**

```bash
cd infra/envs/dev
terraform init
terraform plan  # ~7 IAM resources
terraform apply
```

## Cost Tracking
- VPC endpoints: ~$36/month
- S3 storage: <$5/month (minimal data)
- EMR (when running): ~$0.30/hr = $216/month if 24/7
- **Action**: Auto-terminate EMR after use!

## AWS Profile
- Profile name: 'marketpulse'
- Region: 'us-east-2'
- User: 'moraran'

## Key Files to Edit (M2)
- 'infra/modules/iam/*' (done, ready to apply)
- 'infra/modules/emr/*' (next to create)
- 'infra/envs/dev/main.tf' (add EMR module call)

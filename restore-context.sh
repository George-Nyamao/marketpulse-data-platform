#!/bin/bash

echo "========================================="
echo "   MARKETPULSE DATA PLATFORM - CONTEXT"
echo "========================================="
echo ""

echo "📍 Current Location:"
pwd
echo ""

echo "🎯 Current Milestone: M2 (EMR Cluster)"
echo "   Status: IAM module ready, need to apply"
echo ""

echo "📊 Infrastructure Summary:"
echo "   - M0 (VPC): 23 resources ✅"
echo "   - M1 (S3/Glue): 24 resources ✅"
echo "   - M2 (IAM): 7 resources 🚧 ready to apply"
echo "   - Total: 47 deployed, 7 pending"
echo ""

echo "🔧 Last Terraform State:"
cd infra/envs/dev 2>/dev/null
if [ $? -eq 0 ]; then
    terraform output 2>/dev/null | head -10
    echo "   ... (run 'terraform output' for full list)"
    cd - > /dev/null
else
    echo "   ⚠️  Not in project directory"
fi
echo ""

echo "📝 Recent Git Activity:"
git log --oneline -5 2>/dev/null || echo "   ⚠️  Not a git repository"
echo ""

echo "🔍 Git Status:"
git status --short 2>/dev/null || echo "   ⚠️  Not a git repository"
echo ""

echo "📚 Key Documents:"
echo "   - docs/progress.md (milestone tracking)"
echo "   - docs/naming-conventions.md"
echo "   - docs/session-20251101-part2.md (today's work)"
echo ""

echo "⏭️  Next Steps:"
echo "   1. cd infra/envs/dev"
echo "   2. terraform init"
echo "   3. terraform plan   # Should show ~7 IAM resources"
echo "   4. terraform apply"
echo "   5. Create EMR module (infra/modules/emr/)"
echo ""

echo "🆘 Quick Help:"
echo "   View progress:  cat docs/progress.md"
echo "   View session:   cat docs/session-20251101-part2.md"
echo "   TF outputs:     cd infra/envs/dev && terraform output"
echo ""

echo "========================================="

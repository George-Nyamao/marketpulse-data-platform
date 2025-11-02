#!/bin/bash
# M1 Completion Script - Run this in next session

echo "=== M1 COMPLETION WORKFLOW ==="
echo ""
echo "1. Review gaps:"
cat docs/M1-GAPS.md
echo ""
echo "2. Next: Update S3 module lifecycle policies"
echo "   File: infra/modules/s3/main.tf"
echo ""
echo "3. Then: Apply changes"
echo "   cd infra/envs/dev"
echo "   terraform plan"
echo "   terraform apply"
echo ""
echo "4. Finally: Write documentation"
echo "   - docs/M1-DECISIONS.md"
echo "   - docs/M1-BAR-RAISER-PREP.md"
echo "   - docs/M1-PROOF.md"
echo ""
echo "See docs/M1-GAPS.md for full details"

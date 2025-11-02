#!/bin/bash
echo "=== MARKETPULSE CONTEXT ==="
echo "Current Milestone: M1 (Storage & Catalog)"
echo ""
echo "Last Known State:"
terraform -chdir=infra/envs/dev output
echo ""
echo "Git Status:"
git status --short
echo ""
echo "Last 3 Commits:"
git log --oneline -3
echo ""
echo "Current Task: Fix S3 lifecycle rules and apply M1"
echo "File to edit: infra/modules/s3/main.tf"

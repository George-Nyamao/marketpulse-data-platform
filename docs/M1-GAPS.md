# M1 Gaps Checklist

## 1. S3 Access Logging
Add logging configuration to raw, silver, gold, artifacts buckets
Target: logs bucket

## 2. Lifecycle Policies
- raw: Add GLACIER_DEEP_ARCHIVE @ 180d
- logs: Change expiry from 30d to 180d
- artifacts: Add STANDARD_IA @ 90d

## 3. Documentation
- Enhance naming-conventions.md with partition details
- Write M1-DECISIONS.md (5-8 sentences)
- Write M1-BAR-RAISER-PREP.md

## 4. Proof Artifacts
Run AWS CLI commands to prove configurations

See session-20251101-part2.md for full context.

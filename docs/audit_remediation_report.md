# M1 Audit Remediation Report

This report summarizes the changes made to the Terraform configuration to address the gaps identified during the M1 audit. The goal of these changes is to align the infrastructure with the coach's recommendations, particularly regarding S3 bucket configurations, IAM policies, and S3 VPC endpoint restrictions.

## Summary of Changes

### 1. S3 Bucket Configurations

The following adjustments have been made to the S3 bucket resources for enhanced cost optimization, data retention, and compliance:

*   **`marketpulse-moraran-dev-raw` Bucket Lifecycle:**
    *   The lifecycle policy for the raw data bucket has been updated to transition objects to `STANDARD_IA` after 30 days, aligning with tighter cost-saving recommendations.
    *   An "abort incomplete multipart uploads" rule has been added to abort incomplete uploads after 7 days, preventing accumulation of incomplete uploads and managing storage costs.
*   **`marketpulse-moraran-dev-silver` and `marketpulse-moraran-dev-gold` Buckets Lifecycle:**
    *   Lifecycle configurations have been added to both the silver and gold environmental buckets. These new policies are set to expire noncurrent versions of objects after 30 days, optimizing storage costs by automatically cleaning up older versions of validated and curated data.
    *   An "abort incomplete multipart uploads" rule has been added to abort incomplete uploads after 7 days, preventing accumulation of incomplete uploads and managing storage costs.
*   **`marketpulse-moraran-dev-logs` Bucket Versioning:**
    *   Versioning has been explicitly enabled for the logs bucket to provide an additional layer of data protection and allow for recovery from accidental deletions or overwrites of log data, enhancing auditability and compliance.
*   **S3 Bucket Policies (TLS and VPCe Enforcement):**
    *   Bucket policies have been added to the `raw`, `silver`, and `gold` buckets to enforce TLS and deny requests not originating from the S3 VPC endpoint. This ensures all data transfers are encrypted and come from within the VPC, enhancing security.
    *   A bucket policy has been added to the `logs` bucket to allow the S3 log delivery service to write logs, ensuring server access logging functions correctly.

### 2. IAM Policy Adjustments (Glue Service Role)

The IAM policies associated with the Glue service role have been refined to adhere strictly to the principle of least privilege, improving the security posture of our data platform:

*   **`AWSGlueServiceRole` Detachment:**
    *   The broad `AWSGlueServiceRole` managed policy has been detached from the Glue service role. This eliminates overly permissive access that was granted by the default AWS managed policy.
*   **Scoped `GlueCatalog` Permissions:**
    *   The `GlueCatalog` permissions within the inline `glue-service-policy` have been narrowed. Instead of granting wildcard access (`"Resource": ["*"]`), the policy now explicitly defines access to specific Glue catalog resources (catalog, databases, and tables) using their ARNs, ensuring Glue jobs can only interact with relevant metadata.
*   **Scoped `CloudWatchLogs` Permissions:**
    *   `CloudWatchLogs` permissions have been tightened. The Glue service role can now write logs to specific log groups and log streams related to Glue jobs, preventing it from interacting with other CloudWatch Logs resources unnecessarily.
*   **KMS Key and Permissions:**
    *   A new KMS key has been defined for Glue encryption.
    *   The `kms:Decrypt` action, along with `kms:Encrypt`, `kms:GenerateDataKey*`, and `kms:DescribeKey`, has been added to the `glue-service-policy`, scoped to the specific KMS key ARN. This ensures Glue jobs have the necessary permissions to interact with KMS-encrypted data while adhering to least privilege.
    *   The KMS key policy has been updated to explicitly trust the Glue service role, the root user of the account, and includes a placeholder for the EMR service role, ensuring future-proof access for relevant services.

### 3. S3 Gateway Endpoint Policy Restriction

The policy for the S3 Gateway VPC Endpoint has been made more granular to restrict access exclusively to the project's S3 buckets:

*   **Targeted S3 Resource Access:**
    *   The endpoint policy has been updated to explicitly list the ARNs of all `marketpulse` project buckets (`raw`, `silver`, `gold`, `logs`, `artifacts`). This prevents unauthorized access to other S3 buckets outside of the project scope through this VPC endpoint, greatly reducing the attack surface.

## Terraform Plan Output

The following `terraform plan` output details the exact infrastructure changes that will be applied:

```
module.iam.aws_iam_role_policy_attachment.glue_service: Refreshing state... [id=marketpulse-dev-glue-service-role-20251102135905225600000001]           
module.s3.aws_s3_bucket.artifacts: Refreshing state... [id=marketpulse-moraran-dev-artifacts]                                                           
module.vpc.aws_vpc.main: Refreshing state... [id=vpc-0dea028fa045e6f28]                                                                                 
module.s3.aws_s3_bucket.logs: Refreshing state... [id=marketpulse-moraran-dev-logs]                                                                     
module.s3.aws_s3_bucket.silver: Refreshing state... [id=marketpulse-moraran-dev-silver]                                                                 
module.vpc.aws_cloudwatch_log_group.vpc_flow_logs: Refreshing state... [id=/aws/vpc/marketpulse-dev]                                                    
module.s3.aws_s3_bucket.gold: Refreshing state... [id=marketpulse-moraran-dev-gold]                                                                     
module.s3.aws_s3_bucket.raw: Refreshing state... [id=marketpulse-moraran-dev-raw]                                                                       
module.iam.data.aws_region.current: Reading...                                                                                                          
data.aws_caller_identity.current: Reading...                                                                                                            
module.iam.data.aws_region.current: Read complete after 0s [id=us-east-2]                                                                               
module.vpc.aws_iam_role.vpc_flow_logs: Refreshing state... [id=marketpulse-dev-vpc-flow-logs-role]                                                      
data.aws_caller_identity.current: Read complete after 0s [id=509256337340]                                                                              
module.iam.data.aws_iam_policy_document.glue_assume_role: Reading...                                                                                    
module.iam.data.aws_iam_policy_document.glue_assume_role: Read complete after 0s [id=2681768870]                                                        
module.iam.data.aws_caller_identity.current: Reading...                                                                                                 
module.iam.data.aws_caller_identity.current: Read complete after 0s [id=509256337340]                                                                   
module.iam.aws_iam_role.glue_service: Refreshing state... [id=marketpulse-dev-glue-service-role]                                                        
module.vpc.aws_iam_role_policy.vpc_flow_logs: Refreshing state... [id=marketpulse-dev-vpc-flow-logs-role:marketpulse-dev-vpc-flow-logs-policy]          
module.s3.aws_s3_bucket_server_side_encryption_configuration.silver: Refreshing state... [id=marketpulse-moraran-dev-silver]                            
module.s3.aws_s3_bucket_versioning.silver: Refreshing state... [id=marketpulse-moraran-dev-silver]                                                      
module.s3.aws_s3_bucket_public_access_block.silver: Refreshing state... [id=marketpulse-moraran-dev-silver]                                             
module.glue.aws_glue_catalog_database.silver: Refreshing state... [id=509256337340:marketpulse_dev_silver]                                              
module.s3.aws_s3_bucket_public_access_block.gold: Refreshing state... [id=marketpulse-moraran-dev-gold]                                                 
module.s3.aws_s3_bucket_versioning.gold: Refreshing state... [id=marketpulse-moraran-dev-gold]                                                          
module.s3.aws_s3_bucket_server_side_encryption_configuration.gold: Refreshing state... [id=marketpulse-moraran-dev-gold]                                
module.s3.aws_s3_bucket_server_side_encryption_configuration.artifacts: Refreshing state... [id=marketpulse-moraran-dev-artifacts]                      
module.s3.aws_s3_bucket_lifecycle_configuration.artifacts: Refreshing state... [id=marketpulse-moraran-dev-artifacts]                                   
module.s3.aws_s3_bucket_public_access_block.artifacts: Refreshing state... [id=marketpulse-moraran-dev-artifacts]                                       
module.s3.aws_s3_bucket_versioning.artifacts: Refreshing state... [id=marketpulse-moraran-dev-artifacts]                                                
module.s3.aws_s3_bucket_public_access_block.logs: Refreshing state... [id=marketpulse-moraran-dev-logs]                                                 
module.s3.aws_s3_bucket_logging.gold: Refreshing state... [id=marketpulse-moraran-dev-gold]                                                             
module.s3.aws_s3_bucket_server_side_encryption_configuration.logs: Refreshing state... [id=marketpulse-moraran-dev-logs]                                
module.s3.aws_s3_bucket_logging.silver: Refreshing state... [id=marketpulse-moraran-dev-silver]                                                         
module.s3.aws_s3_bucket_logging.artifacts: Refreshing state... [id=marketpulse-moraran-dev-artifacts]                                                   
module.s3.aws_s3_bucket_lifecycle_configuration.logs: Refreshing state... [id=marketpulse-moraran-dev-logs]                                             
module.glue.aws_glue_catalog_database.gold: Refreshing state... [id=509256337340:marketpulse_dev_gold]                                                  
module.s3.aws_s3_bucket_server_side_encryption_configuration.raw: Refreshing state... [id=marketpulse-moraran-dev-raw]                                  
module.s3.aws_s3_bucket_logging.raw: Refreshing state... [id=marketpulse-moraran-dev-raw]                                                               
module.s3.aws_s3_bucket_versioning.raw: Refreshing state... [id=marketpulse-moraran-dev-raw]                                                            
module.s3.aws_s3_bucket_lifecycle_configuration.raw: Refreshing state... [id=marketpulse-moraran-dev-raw]                                               
module.s3.aws_s3_bucket_public_access_block.raw: Refreshing state... [id=marketpulse-moraran-dev-raw]                                                   
module.glue.aws_glue_catalog_database.bronze: Refreshing state... [id=509256337340:marketpulse_dev_bronze]                                              
module.iam.aws_iam_role_policy.glue_service: Refreshing state... [id=marketpulse-dev-glue-service-role:glue-service-policy]                             
module.vpc.aws_route_table.private: Refreshing state... [id=rtb-09b82090966916021]                                                                      
module.vpc.aws_flow_log.main: Refreshing state... [id=fl-0d60bc9c46a0847e7]                                                                             
module.vpc.aws_internet_gateway.main: Refreshing state... [id=igw-0139c298263399654]                                                                    
module.vpc.aws_subnet.public[0]: Refreshing state... [id=subnet-07e9043c9bbd47730]                                                                      
module.vpc.aws_subnet.public[1]: Refreshing state... [id=subnet-0b95017b00607739e]                                                                      
module.vpc.aws_security_group.vpc_endpoints: Refreshing state... [id=sg-04de0295a601187ff]                                                              
module.vpc.aws_subnet.private[1]: Refreshing state... [id=subnet-099a96b76f471aad8]                                                                     
module.vpc.aws_subnet.private[0]: Refreshing state... [id=subnet-0fe2aedcc10ad20e6]                                                                     
module.vpc.aws_route_table.public: Refreshing state... [id=rtb-022b3d3dfbc975c47]                                                                       
module.vpc.aws_route_table_association.private[1]: Refreshing state... [id=rtbassoc-0410e647ec04ca1ea]                                                  
module.vpc.aws_route_table_association.private[0]: Refreshing state... [id=rtbassoc-071c043b0e02f3825]                                                  
module.vpc.aws_vpc_endpoint.glue: Refreshing state... [id=vpce-04ffd36a05bcf8108]                                                                       
module.vpc.aws_vpc_endpoint.sts: Refreshing state... [id=vpce-0746a9489a14f9fad]                                                                        
module.vpc.aws_vpc_endpoint.logs: Refreshing state... [id=vpce-0c02dd0e5bd751659]                                                                       
module.vpc.aws_vpc_endpoint.kms: Refreshing state... [id=vpce-04f98c9304d3682dc]                                                                        
module.vpc.aws_vpc_endpoint.ec2: Refreshing state... [id=vpce-0ca515e5c4676e36e]                                                                        
module.vpc.aws_route_table_association.public[0]: Refreshing state... [id=rtbassoc-0ca86df8dd0a35cea]                                                   
module.vpc.aws_route_table_association.public[1]: Refreshing state... [id=rtbassoc-0b11c7e9bca562c2e]                                                   
module.vpc.aws_vpc_endpoint.s3: Refreshing state... [id=vpce-0d8c69ee63bf89dc4]                                                                         
                                                                                                                                                        
Terraform used the selected providers to generate the following execution plan. Resource actions are indicated with the following symbols:              
  + create                                                                                                                                              
  ~ update in-place                                                                                                                                     
  - destroy                                                                                                                                             
 <= read (data resources)                                                                                                                               
                                                                                                                                                        
Terraform will perform the following actions:                                                                                                           
                                                                                                                                                        
  # aws_kms_alias.glue_encryption will be created                                                                                                       
  + resource "aws_kms_alias" "glue_encryption" {                                                                                                        
      + arn            = (known after apply)                                                                                                            
      + id             = (known after apply)                                                                                                            
      + name           = "alias/marketpulse-dev-glue-encryption-key"                                                                                    
      + name_prefix    = (known after apply)                                                                                                            
      + target_key_arn = (known after apply)                                                                                                            
      + target_key_id  = (known after apply)                                                                                                            
    }                                                                                                                                                   
                                                                                                                                                        
  # aws_kms_key.glue_encryption will be created                                                                                                         
  + resource "aws_kms_key" "glue_encryption" {                                                                                                          
      + arn                                = (known after apply)                                                                                        
      + bypass_policy_lockout_safety_check = false                                                                                                      
      + customer_master_key_spec           = "SYMMETRIC_DEFAULT"                                                                                        
      + deletion_window_in_days            = 10                                                                                                         
      + description                        = "KMS key for Glue encryption"                                                                              
      + enable_key_rotation                = true                                                                                                       
      + id                                 = (known after apply)                                                                                        
      + is_enabled                         = true                                                                                                       
      + key_id                             = (known after apply)                                                                                        
      + key_usage                          = "ENCRYPT_DECRYPT"                                                                                          
      + multi_region                       = (known after apply)                                                                                        
      + policy                             = jsonencode(                                                                                                
            {                                                                                                                                           
              + Statement = [                                                                                                                           
                  + {                                                                                                                                   
                      + Action    = "kms:*"                                                                                                             
                      + Effect    = "Allow"                                                                                                             
                      + Principal = {                                                                                                                   
                          + AWS = "arn:aws:iam::509256337340:root"                                                                                      
                        }                                                                                                                               
                      + Resource  = "*"                                                                                                                 
                      + Sid       = "EnableIAMRootUserAccess"                                                                                           
                    },                                                                                                                                  
                  + {                                                                                                                                   
                      + Action    = [                                                                                                                   
                          + "kms:Encrypt",                                                                                                              
                          + "kms:Decrypt",                                                                                                              
                          + "kms:ReEncrypt*",                                                                                                           
                          + "kms:GenerateDataKey*",                                                                                                     
                          + "kms:DescribeKey",                                                                                                          
                        ]                                                                                                                               
                      + Effect    = "Allow"                                                                                                             
                      + Principal = {                                                                                                                   
                          + AWS = "arn:aws:iam::509256337340:role/marketpulse-dev-glue-service-role"                                                    
                        }                                                                                                                               
                      + Resource  = "*"                                                                                                                 
                      + Sid       = "AllowGlueServiceRoleToUseKey"                                                                                      
                    },                                                                                                                                  
                  + {                                                                                                                                   
                      + Action    = [                                                                                                                   
                          + "kms:Encrypt",                                                                                                              
                          + "kms:Decrypt",                                                                                                              
                          + "kms:ReEncrypt*",                                                                                                           
                          + "kms:GenerateDataKey*",                                                                                                     
                          + "kms:DescribeKey",                                                                                                          
                        ]                                                                                                                               
                      + Effect    = "Allow"                                                                                                             
                      + Principal = {                                                                                                                   
                          + AWS = "arn:aws:iam::509256337340:role/marketpulse-dev-emr-service-role"                                                     
                        }                                                                                                                               
                      + Resource  = "*"                                                                                                                 
                      + Sid       = "AllowEMRServiceRoleToUseKey"                                                                                       
                    },                                                                                                                                  
                ]                                                                                                                                       
              + Version   = "2012-10-17"                                                                                                                
            }                                                                                                                                           
        )                                                                                                                                               
      + rotation_period_in_days            = (known after apply)                                                                                        
      + tags                               = {                                                                                                          
          + "Environment" = "dev"                                                                                                                       
          + "Name"        = "marketpulse-dev-glue-encryption-key"                                                                                       
        }                                                                                                                                               
      + tags_all                           = {                                                                                                          
          + "Environment" = "dev"                                                                                                                       
          + "ManagedBy"   = "Terraform"                                                                                                                 
          + "Name"        = "marketpulse-dev-glue-encryption-key"                                                                                       
          + "Owner"       = "moraran"                                                                                                                   
          + "Project"     = "MarketPulse"                                                                                                               
        }                                                                                                                                               
    }                                                                                                                                                   
                                                                                                                                                        
  # module.iam.aws_iam_role_policy.glue_service will be updated in-place                                                                                
  ~ resource "aws_iam_role_policy" "glue_service" {                                                                                                     
        id          = "marketpulse-dev-glue-service-role:glue-service-policy"                                                                           
        name        = "glue-service-policy"                                                                                                             
      ~ policy      = jsonencode(                                                                                                                       
            {                                                                                                                                           
              - Statement = [                                                                                                                           
                  - {                                                                                                                                   
                      - Action   = [                                                                                                                    
                          - "s3:ListBucket",                                                                                                            
                          - "s3:GetObject",                                                                                                             
                        ]                                                                                                                               
                      - Effect   = "Allow"                                                                                                              
                      - Resource = [                                                                                                                    
                          - "arn:aws:s3:::marketpulse-moraran-dev-raw/*",                                                                               
                          - "arn:aws:s3:::marketpulse-moraran-dev-raw",                                                                                 
                        ]                                                                                                                               
                      - Sid      = "ReadRawBucket"                                                                                                      
                    },                                                                                                                                  
                  - {                                                                                                                                   
                      - Action   = [                                                                                                                    
                          - "s3:PutObject",                                                                                                             
                          - "s3:ListBucket",                                                                                                            
                          - "s3:GetObject",                                                                                                             
                          - "s3:DeleteObject",                                                                                                          
                        ]                                                                                                                               
                      - Effect   = "Allow"                                                                                                              
                      - Resource = [                                                                                                                    
                          - "arn:aws:s3:::marketpulse-moraran-dev-silver/*",                                                                            
                          - "arn:aws:s3:::marketpulse-moraran-dev-silver",                                                                              
                          - "arn:aws:s3:::marketpulse-moraran-dev-gold/*",                                                                              
                          - "arn:aws:s3:::marketpulse-moraran-dev-gold",                                                                                
                        ]                                                                                                                               
                      - Sid      = "ReadWriteSilverGold"                                                                                                
                    },                                                                                                                                  
                  - {                                                                                                                                   
                      - Action   = "s3:PutObject"                                                                                                       
                      - Effect   = "Allow"                                                                                                              
                      - Resource = "arn:aws:s3:::marketpulse-moraran-dev-logs/glue-logs/*"                                                              
                      - Sid      = "WriteLogs"                                                                                                          
                    },                                                                                                                                  
                  - {                                                                                                                                   
                      - Action   = [                                                                                                                    
                          - "glue:UpdateTable",                                                                                                         
                          - "glue:GetTable",                                                                                                            
                          - "glue:GetPartitions",                                                                                                       
                          - "glue:GetDatabase",                                                                                                         
                          - "glue:CreateTable",                                                                                                         
                          - "glue:CreatePartition",                                                                                                     
                          - "glue:BatchCreatePartition",                                                                                                
                        ]                                                                                                                               
                      - Effect   = "Allow"                                                                                                              
                      - Resource = "*"                                                                                                                  
                      - Sid      = "GlueCatalog"                                                                                                        
                    },                                                                                                                                  
                  - {                                                                                                                                   
                      - Action   = [                                                                                                                    
                          - "logs:PutLogEvents",                                                                                                        
                          - "logs:CreateLogStream",                                                                                                     
                          - "logs:CreateLogGroup",                                                                                                      
                        ]                                                                                                                               
                      - Effect   = "Allow"                                                                                                              
                      - Resource = "arn:aws:logs:*:*:/aws-glue/*"                                                                                       
                      - Sid      = "CloudWatchLogs"                                                                                                     
                    },                                                                                                                                  
                ]                                                                                                                                       
              - Version   = "2012-10-17"                                                                                                                
            }                                                                                                                                           
        ) -> (known after apply)                                                                                                                        
        # (2 unchanged attributes hidden)                                                                                                               
    }                                                                                                                                                   
                                                                                                                                                        
  # module.iam.aws_iam_role_policy_attachment.glue_service will be destroyed                                                                            
  # (because aws_iam_role_policy_attachment.glue_service is not in configuration)                                                                       
  - resource "aws_iam_role_policy_attachment" "glue_service" {                                                                                          
      - id         = "marketpulse-dev-glue-service-role-20251102135905225600000001" -> null                                                             
      - policy_arn = "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole" -> null                                                                  
      - role       = "marketpulse-dev-glue-service-role" -> null                                                                                        
    }                                                                                                                                                   
                                                                                                                                                        
  # module.s3.aws_s3_bucket_lifecycle_configuration.gold will be created                                                                                
  + resource "aws_s3_bucket_lifecycle_configuration" "gold" {                                                                                           
      + bucket                                 = "marketpulse-moraran-dev-gold"                                                                         
      + expected_bucket_owner                  = (known after apply)                                                                                    
      + id                                     = (known after apply)                                                                                    
      + transition_default_minimum_object_size = "all_storage_classes_128K"                                                                             
                                                                                                                                                        
      + rule {                                                                                                                                          
          + id     = "expire-noncurrent-versions"                                                                                                       
          + status = "Enabled"                                                                                                                          
            # (1 unchanged attribute hidden)                                                                                                            
                                                                                                                                                        
          + abort_incomplete_multipart_upload {                                                                                                         
              + days_after_initiation = 7                                                                                                               
            }                                                                                                                                           
                                                                                                                                                        
          + filter {                                                                                                                                    
                # (1 unchanged attribute hidden)                                                                                                        
            }                                                                                                                                           
                                                                                                                                                        
          + noncurrent_version_expiration {                                                                                                             
              + noncurrent_days = 30                                                                                                                    
            }                                                                                                                                           
        }                                                                                                                                               
    }                                                                                                                                                   
                                                                                                                                                        
  # module.s3.aws_s3_bucket_lifecycle_configuration.raw will be updated in-place                                                                        
  ~ resource "aws_s3_bucket_lifecycle_configuration" "raw" {                                                                                            
        id                                     = "marketpulse-moraran-dev-raw"                                                                          
        # (3 unchanged attributes hidden)                                                                                                               
                                                                                                                                                        
      ~ rule {                                                                                                                                          
            id     = "transition-to-ia-then-glacier"                                                                                                    
            # (2 unchanged attributes hidden)                                                                                                           
                                                                                                                                                        
          + abort_incomplete_multipart_upload {                                                                                                         
              + days_after_initiation = 7                                                                                                               
            }                                                                                                                                           
                                                                                                                                                        
          - transition {                                                                                                                                
              - days          = 90 -> null                                                                                                              
              - storage_class = "STANDARD_IA" -> null                                                                                                   
            }                                                                                                                                           
          + transition {                                                                                                                                
              + days          = 30                                                                                                                      
              + storage_class = "STANDARD_IA"                                                                                                           
            }                                                                                                                                           
                                                                                                                                                        
            # (3 unchanged blocks hidden)                                                                                                               
        }                                                                                                                                               
    }                                                                                                                                                   
                                                                                                                                                        
  # module.s3.aws_s3_bucket_lifecycle_configuration.silver will be created                                                                              
  + resource "aws_s3_bucket_lifecycle_configuration" "silver" {                                                                                         
      + bucket                                 = "marketpulse-moraran-dev-silver"                                                                       
      + expected_bucket_owner                  = (known after apply)                                                                                    
      + id                                     = (known after apply)                                                                                    
      + transition_default_minimum_object_size = "all_storage_classes_128K"                                                                             
                                                                                                                                                        
      + rule {                                                                                                                                          
          + id     = "expire-noncurrent-versions"                                                                                                       
          + status = "Enabled"                                                                                                                          
            # (1 unchanged attribute hidden)                                                                                                            
                                                                                                                                                        
          + abort_incomplete_multipart_upload {                                                                                                         
              + days_after_initiation = 7                                                                                                               
            }

          + filter {
                # (1 unchanged attribute hidden)
            }

          + noncurrent_version_expiration {
              + noncurrent_days = 30
            }
        }
    }

  # module.s3.aws_s3_bucket_policy.gold will be created
  + resource "aws_s3_bucket_policy" "gold" {
      + bucket = "marketpulse-moraran-dev-gold"
      + id     = (known after apply)
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + Bool = {
                              + "aws:SecureTransport" = "false"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-gold",
                          + "arn:aws:s3:::marketpulse-moraran-dev-gold/*",
                        ]
                      + Sid       = "DenyNonTLSRequests"
                    },
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + StringNotEquals = {
                              + "aws:sourceVpce" = "vpce-0d8c69ee63bf89dc4"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-gold",
                          + "arn:aws:s3:::marketpulse-moraran-dev-gold/*",
                        ]
                      + Sid       = "DenyRequestsOutsideVPCe"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # module.s3.aws_s3_bucket_policy.logs will be created
  + resource "aws_s3_bucket_policy" "logs" {
      + bucket = "marketpulse-moraran-dev-logs"
      + id     = (known after apply)
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:PutObject"
                      + Effect    = "Allow"
                      + Principal = {
                          + Service = "logging.s3.amazonaws.com"
                        }
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-logs",
                          + "arn:aws:s3:::marketpulse-moraran-dev-logs/*",
                        ]
                      + Sid       = "AllowS3LogDelivery"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # module.s3.aws_s3_bucket_policy.raw will be created
  + resource "aws_s3_bucket_policy" "raw" {
      + bucket = "marketpulse-moraran-dev-raw"
      + id     = (known after apply)
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + Bool = {
                              + "aws:SecureTransport" = "false"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-raw",
                          + "arn:aws:s3:::marketpulse-moraran-dev-raw/*",
                        ]
                      + Sid       = "DenyNonTLSRequests"
                    },
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + StringNotEquals = {
                              + "aws:sourceVpce" = "vpce-0d8c69ee63bf89dc4"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-raw",
                          + "arn:aws:s3:::marketpulse-moraran-dev-raw/*",
                        ]
                      + Sid       = "DenyRequestsOutsideVPCe"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # module.s3.aws_s3_bucket_policy.silver will be created
  + resource "aws_s3_bucket_policy" "silver" {
      + bucket = "marketpulse-moraran-dev-silver"
      + id     = (known after apply)
      + policy = jsonencode(
            {
              + Statement = [
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + Bool = {
                              + "aws:SecureTransport" = "false"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-silver",
                          + "arn:aws:s3:::marketpulse-moraran-dev-silver/*",
                        ]
                      + Sid       = "DenyNonTLSRequests"
                    },
                  + {
                      + Action    = "s3:*"
                      + Condition = {
                          + StringNotEquals = {
                              + "aws:sourceVpce" = "vpce-0d8c69ee63bf89dc4"
                            }
                        }
                      + Effect    = "Deny"
                      + Principal = "*"
                      + Resource  = [
                          + "arn:aws:s3:::marketpulse-moraran-dev-silver",
                          + "arn:aws:s3:::marketpulse-moraran-dev-silver/*",
                        ]
                      + Sid       = "DenyRequestsOutsideVPCe"
                    },
                ]
              + Version   = "2012-10-17"
            }
        )
    }

  # module.s3.aws_s3_bucket_versioning.logs will be created
  + resource "aws_s3_bucket_versioning" "logs" {
      + bucket = "marketpulse-moraran-dev-logs"
      + id     = (known after apply)

      + versioning_configuration {
          + mfa_delete = (known after apply)
          + status     = "Enabled"
        }
    }

  # module.vpc.aws_vpc_endpoint.s3 will be updated in-place
  ~ resource "aws_vpc_endpoint" "s3" {
        id                         = "vpce-0d8c69ee63bf89dc4"
      ~ policy                     = jsonencode(
          ~ {
              ~ Statement = [
                  ~ {
                      ~ Resource  = [
                          - "arn:aws:s3:::marketpulse-moraran-*/*",
                          - "arn:aws:s3:::marketpulse-moraran-*",
                          - "arn:aws:s3:::tfstate-moraran-global/*",
                          - "arn:aws:s3:::tfstate-moraran-global",
                          + "arn:aws:s3:::marketpulse-moraran-dev-raw",
                          + "arn:aws:s3:::marketpulse-moraran-dev-raw/*",
                          + "arn:aws:s3:::marketpulse-moraran-dev-silver",
                          + "arn:aws:s3:::marketpulse-moraran-dev-silver/*",
                          + "arn:aws:s3:::marketpulse-moraran-dev-gold",
                          + "arn:aws:s3:::marketpulse-moraran-dev-gold/*",
                          + "arn:aws:s3:::marketpulse-moraran-dev-logs",
                          + "arn:aws:s3:::marketpulse-moraran-dev-logs/*",
                          + "arn:aws:s3:::marketpulse-moraran-dev-artifacts",
                          + "arn:aws:s3:::marketpulse-moraran-dev-artifacts/*",
                        ]
                        # (3 unchanged attributes hidden)
                    },
                ]
                # (1 unchanged attribute hidden)
            }
        )
        tags                       = {
            "Name" = "marketpulse-dev-s3-endpoint"
        }
        # (20 unchanged attributes hidden)

        # (1 unchanged block hidden)
    }

Plan: 13 to add, 3 to change, 1 to destroy.
```

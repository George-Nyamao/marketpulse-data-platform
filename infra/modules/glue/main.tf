# Bronze (Raw) Database
resource "aws_glue_catalog_database" "bronze" {
  name        = "${var.project_name}_${var.environment}_bronze"
  description = "Bronze layer - raw ingested data"

  location_uri = "s3://${var.raw_bucket_name}/"

  tags = {
    Name  = "${var.project_name}_${var.environment}_bronze"
    Layer = "Bronze"
  }
}

# Silver (Validated) Database
resource "aws_glue_catalog_database" "silver" {
  name        = "${var.project_name}_${var.environment}_silver"
  description = "Silver layer - validated and normalized data"

  location_uri = "s3://${var.silver_bucket_name}/"

  tags = {
    Name  = "${var.project_name}_${var.environment}_silver"
    Layer = "Silver"
  }
}

# Gold (Curated) Database
resource "aws_glue_catalog_database" "gold" {
  name        = "${var.project_name}_${var.environment}_gold"
  description = "Gold layer - business-ready aggregations and models"

  location_uri = "s3://${var.gold_bucket_name}/"

  tags = {
    Name  = "${var.project_name}_${var.environment}_gold"
    Layer = "Gold"
  }
}

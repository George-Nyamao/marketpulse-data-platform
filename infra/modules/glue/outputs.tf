output "bronze_database_name" {
  description = "Bronze Glue database name"
  value       = aws_glue_catalog_database.bronze.name
}

output "silver_database_name" {
  description = "Silver Glue database name"
  value       = aws_glue_catalog_database.silver.name
}

output "gold_database_name" {
  description = "Gold Glue database name"
  value       = aws_glue_catalog_database.gold.name
}

output "all_database_names" {
  description = "Map of all database names"
  value = {
    bronze = aws_glue_catalog_database.bronze.name
    silver = aws_glue_catalog_database.silver.name
    gold   = aws_glue_catalog_database.gold.name
  }
}

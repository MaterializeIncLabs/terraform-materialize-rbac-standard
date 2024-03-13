terraform {
  required_providers {
    materialize = {
      source = "MaterializeInc/materialize"
      version = "0.6.5"
    }
  }
}

provider "materialize" {
  password       = "your_app_password" 
  default_region = "aws/us-east-1"
  endpoint = "https://admin.staging.cloud.materialize.com"
  cloud_endpoint = "https://api.staging.cloud.materialize.com"
  base_endpoint = "https://staging.cloud.materialize.com"
}

variable "all_cluster_schema_database_perms" {
  type    = set(string)
  default = [ "USAGE", "CREATE" ]
}

variable "all_table_perms" {
  type    = set(string)
  default = [ "INSERT", "SELECT", "UPDATE", "DELETE" ]
}

resource "materialize_database" "databases" {
  for_each = var.team_names
  name = each.value
}

resource "materialize_cluster" "quickstart" {
  count = var.manage_quickstart_cluster ? 1 : 0
  name = "quickstart"
  size = var.quickstart_cluster_size
  replication_factor = var.quickstart_cluster_replication_factor
}

resource "materialize_cluster" "dev" {
    for_each = var.create_dev_clusters ? var.team_names : []
    name = "${each.value}_dev"
    size = var.dev_clusters_size
    replication_factor = var.dev_clusters_replication_factor
    ownership_role = materialize_role.devrole[each.value].name
}

resource "materialize_schema" "dev" {
  name          = "dev"
  for_each      = var.team_names
  database_name = materialize_database.databases[each.value].name
  ownership_role = materialize_role.devrole[each.value].name
}

resource "materialize_role" "devrole" {
  for_each = var.team_names
  name = "${each.value}_devrole"
}

resource "materialize_role_parameter" "devrole_database_role_parameter" {
  for_each = var.team_names
  role_name      = "${each.value}_devrole"
  variable_name  = "database"
  variable_value = "${each.value}"
}

resource "materialize_role_parameter" "devrole_cluster_role_parameter" {
  for_each = var.create_dev_clusters ? var.team_names : []
  role_name      = "${each.value}_devrole"
  variable_name  = "cluster"
  variable_value = "${each.value}_dev"
}

resource "materialize_role_parameter" "devrole_searchpath_role_parameter" {
  for_each = var.team_names
  role_name      = "${each.value}_devrole"
  variable_name  = "search_path"
  variable_value = "dev"
}

locals {
  team_cluster_schema_database_perms_dev = {
    for pair in setproduct(var.team_names, var.all_cluster_schema_database_perms) :
      "${pair[0]}_${pair[1]}" => {
        database  = materialize_database.databases[pair[0]].name
        permission  = pair[1]
        role = materialize_role.devrole[pair[0]].name
        schema = materialize_schema.dev[pair[0]].name
      }
  }
}

resource "materialize_database_grant" "db_grant_to_dev" {
  for_each      = local.team_cluster_schema_database_perms_dev
  privilege     = each.value.permission
  role_name     = each.value.role
  database_name = each.value.database
}

resource "materialize_schema_grant" "dev_schema_to_dev" {
  for_each      = local.team_cluster_schema_database_perms_dev
  privilege     = each.value.permission
  role_name     = each.value.role
  database_name = each.value.database
  schema_name   = each.value.schema
}

resource "materialize_schema_grant" "sandbox_schema_to_dev" {
  for_each      = local.team_cluster_schema_database_perms_dev
  privilege     = each.value.permission
  role_name     = each.value.role
  database_name = "materialize"
  schema_name   = materialize_schema.sandbox.name
}

resource "materialize_schema_grant" "prod_schema_usage_to_dev" {
  for_each = var.team_names    
  privilege   = "USAGE"
  role_name     = materialize_role.devrole[each.value].name
  database_name = materialize_database.databases[each.value].name
  schema_name   = materialize_schema.prod[each.value].name
}

resource "materialize_cluster_grant" "quickstart_cluster_grant_devrole" {
  for_each = var.team_names
  privilege     = "USAGE"
  cluster_name  = var.manage_quickstart_cluster ? materialize_cluster.quickstart[0].name : "quickstart"
  role_name     = materialize_role.devrole[each.value].name
}

resource "materialize_grant_system_privilege" "dev_clustercreate" {
  for_each = var.dev_create_clusters_permission ? var.team_names : []
  privilege = "CREATECLUSTER"
  role_name = materialize_role.devrole[each.value].name
}

resource "materialize_table_grant_default_privilege" "prod_table_default_devrole" {
  for_each = var.team_names
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.devrole[each.value].name
  privilege = "SELECT"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.prod[each.value].name
}

locals {
  team_table_perms_dev = {
    for pair in setproduct(var.team_names, var.all_table_perms) :
      "${pair[0]}_${pair[1]}" => {
        database  = materialize_database.databases[pair[0]].name
        permission  = pair[1]
        role = materialize_role.devrole[pair[0]].name
        schema = materialize_schema.dev[pair[0]].name
      }
  }
}

resource "materialize_table_grant_default_privilege" "dev_table_default" {
  for_each = local.team_table_perms_dev
  target_role_name = "PUBLIC"
  grantee_name = each.value.role
  privilege = each.value.permission
  database_name = each.value.database
  schema_name = each.value.schema
}

resource "materialize_type_grant_default_privilege" "dev_type_default" {
  for_each = var.team_names
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.devrole[each.value].name
  privilege = "USAGE"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.dev[each.value].name
}

resource "materialize_connection_grant_default_privilege" "dev_connection_default" {
  for_each = var.team_names
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.devrole[each.value].name
  privilege = "USAGE"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.dev[each.value].name
}

resource "materialize_secret_grant_default_privilege" "dev_secret_default" {
  for_each = var.team_names
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.devrole[each.value].name
  privilege = "USAGE"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.dev[each.value].name
}

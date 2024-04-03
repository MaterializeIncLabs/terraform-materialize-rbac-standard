resource "materialize_cluster" "prod" {
  for_each = var.team_names
  name = "${each.value}-prod"
  size = var.prod_cluster_size
  replication_factor = var.prod_cluster_replication_factor
  ownership_role = materialize_role.prodrole[each.value].name
}

resource "materialize_schema" "prod" {
  name          = "prod"
  for_each      = var.team_names
  database_name = materialize_database.databases[each.value].name
  ownership_role = materialize_role.prodrole[each.value].name
}

resource "materialize_role" "prodrole" {
  for_each = var.team_names
  name = "${each.value}-prodrole"
}

resource "materialize_role_parameter" "prodrole_database_role_parameter" {
  for_each = var.team_names
  role_name      = "${each.value}-prodrole"
  variable_name  = "database"
  variable_value = "${each.value}"
}

resource "materialize_role_parameter" "prodrole_cluster_role_parameter" {
  for_each = var.team_names
  role_name      = "${each.value}-prodrole"
  variable_name  = "cluster"
  variable_value = "${each.value}-prod"
}

resource "materialize_role_parameter" "prodrole_searchpath_role_parameter" {
  for_each = var.team_names
  role_name      = "${each.value}-prodrole"
  variable_name  = "search_path"
  variable_value = "prod"
}

locals {
  team_cluster_schema_database_perms = {
    for pair in setproduct(var.team_names, var.all_cluster_schema_database_perms) :
      "${pair[0]}-${pair[1]}" => {
        database  = materialize_database.databases[pair[0]].name
        permission  = pair[1]
        role = materialize_role.prodrole[pair[0]].name
        cluster = materialize_cluster.prod[pair[0]].name
        schema = materialize_schema.prod[pair[0]].name
      }
  }
}

resource "materialize_database_grant" "db_grant_to_prod" {
  for_each      = local.team_cluster_schema_database_perms
  privilege     = each.value.permission
  role_name     = each.value.role
  database_name = each.value.database
}


resource "materialize_cluster_grant" "prod_cluster_grant_prodrole" {
  for_each      = local.team_cluster_schema_database_perms
  privilege     = each.value.permission
  cluster_name = each.value.cluster
  role_name     = each.value.role
}

resource "materialize_schema_grant" "prod_schema_to_prod" {
  for_each      = local.team_cluster_schema_database_perms
  privilege     = each.value.permission
  role_name     = each.value.role
  database_name = each.value.database
  schema_name   = each.value.schema
}

resource "materialize_grant_system_privilege" "prod_clustercreate" {
  privilege = "CREATECLUSTER"
  for_each = materialize_role.prodrole
  role_name = each.value.name
}

locals {
  team_table_perms = {
    for pair in setproduct(var.team_names, var.all_table_perms) :
      "${pair[0]}-${pair[1]}" => {
        database  = materialize_database.databases[pair[0]].name
        permission  = pair[1]
        role = materialize_role.prodrole[pair[0]].name
        cluster = materialize_cluster.prod[pair[0]].name
        schema = materialize_schema.prod[pair[0]].name
      }
  }
}

resource "materialize_table_grant_default_privilege" "prod_table_default" {
  for_each = local.team_table_perms
  target_role_name = "PUBLIC"
  grantee_name = each.value.role
  privilege = each.value.permission
  database_name = each.value.database
  schema_name = each.value.schema
}

resource "materialize_type_grant_default_privilege" "prod_type_default" {
  for_each = var.team_names
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.prodrole[each.value].name
  privilege = "USAGE"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.prod[each.value].name
}

resource "materialize_connection_grant_default_privilege" "prod_connection_default" {
  for_each = var.team_names
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.prodrole[each.value].name
  privilege = "USAGE"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.prod[each.value].name
}

resource "materialize_secret_grant_default_privilege" "prod_secret_default" {
  for_each = var.team_names    
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.prodrole[each.value].name
  privilege = "USAGE"
  database_name = materialize_database.databases[each.value].name
  schema_name = materialize_schema.prod[each.value].name
}
resource "materialize_schema" "sandbox" {
  name          = "sandbox"
  database_name = "materialize"
}

resource "materialize_role" "sandboxrole" {
  name = "sandboxrole"
}

resource "materialize_role_parameter" "sandboxrole_database_role_parameter" {
  role_name      = "sandboxrole"
  variable_name  = "database"
  variable_value = "materialize"
}

resource "materialize_role_parameter" "prodrole_cluster_role_parameter" {
  role_name      = "sandboxrole"
  variable_name  = "cluster"
  variable_value = "quickstart"
}

resource "materialize_role_parameter" "prodrole_searchpath_role_parameter" {
  role_name      = "sandboxrole"
  variable_name  = "search_path"
  variable_value = "sandbox"
}

resource "materialize_database_grant" "db_grant_to_sandbox" {
  privilege     = "USAGE"
  role_name     = materialize_role.sandboxrole.name
  database_name = "materialize"
}

resource "materialize_schema_grant" "sandbox_schema_to_sandbox" {
  privilege     = "USAGE"
  role_name     = materialize_role.sandboxrole.name
  database_name = "materialize"
  schema_name   = materialize_schema.sandbox.name
}

resource "materialize_cluster_grant" "quickstart_cluster_grant_sandboxrole" {
  privilege     = "USAGE"
  cluster_name = var.manage_quickstart_cluster ? materialize_cluster.quickstart[0].name : "quickstart"
  role_name     = materialize_role.sandboxrole.name
}

resource "materialize_table_grant_default_privilege" "sandbox_table_default" {
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.sandboxrole.name
  for_each = var.all_table_perms
  privilege = each.value
  database_name = "materialize"
  schema_name = materialize_schema.sandbox.name
}

resource "materialize_type_grant_default_privilege" "sandbox_type_default" {
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.sandboxrole.name
  privilege = "USAGE"
  database_name = "materialize"
  schema_name = materialize_schema.sandbox.name
}

resource "materialize_connection_grant_default_privilege" "sandbox_connection_default" {
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.sandboxrole.name
  privilege = "USAGE"
  database_name = "materialize"
  schema_name = materialize_schema.sandbox.name
}

resource "materialize_secret_grant_default_privilege" "sandbox_secret_default" {
  target_role_name = "PUBLIC"
  grantee_name = materialize_role.sandboxrole.name
  privilege = "USAGE"
  database_name = "materialize"
  schema_name = materialize_schema.sandbox.name
}
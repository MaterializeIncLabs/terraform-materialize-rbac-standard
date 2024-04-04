# materialize-rbac-standard
A standardized organization of RBAC roles and permissions for multi-environment setups and one or many independent teams

## Goal
This is meant to be a standard, tested approach to mapping RBAC permissions onto an org. 
It should provide an easy way to onboard a secure model.

## Description

This model is meant to support any number of independent teams working in Materialize. Both entitlements and deployments are to be separate for each team. 

This model asserts that there will be 3 main roles per team:

*_teamname_\_prodrole* : this/these role(s) should ideally only be granted to the CI/CD system for creating and manipulating objects in the production schema. this role(s) has no rights to dev or sandbox schemas. 

*_teamname_\_devrole*  : this/these role(s) is the role most humans should be using that are working in the system. it has full rights to development resources within the team. It also has read rights on production, but _not_ rights to use the production cluster. this means if you want to utilize prod data from within dev, you it would need to be read from a materialized view and re-indexed on the dev cluster to avoid consuming prod resources. this will allow for partial DAG downstream development models.

*sandboxrole* : this is a limited, walled off environment for people to experiment with Materialize. 

The template will create a new database for each team, as configured in the team_names set in config.tf . It will create a dev and prod schema in each new database. Roles will be separate for each database, to allow independent teams complete autonomy.

The template will create a prod cluster for each team, with the size and number of replicas controlled in the config.
It will also optionally create a dev cluster for each team.



## Entitlements Chart

### Prod Role

| Environment | Resource             | Entitlement    |
| ----------- | -------------------- | -------------- |
| prod        | database             | all            |
| prod        | cluster              | all            |
| prod        | schema               | all            |
| prod        | system               | cluster create |
| prod        | table (default)      | all            |
| prod        | type (default)       | all            |
| prod        | connection (default) | all            |
| prod        | secret (default)     | all            |

### Dev Role

| Environment | Resource             | Entitlement               |
| ----------- | -------------------- | ------------------------- |
| dev         | database             | all                       |
| dev         | cluster (optional)   | all                       |
| dev         | schema               | all                       |
| sandbox     | schema               | all                       |
| prod        | schema               | usage                     |
| sandbox     | quickstart cluster   | usage                     |
| prod        | system               | cluster create (optional) |
| prod        | table (default)      | select                    |
| dev         | table (default)      | all                       |
| dev         | type (default)       | all                       |
| dev         | connection (default) | all                       |
| dev         | secret (default)     | all                       |

### Sandbox Role

| Environment | Resource               | Entitlement |
| ----------- | ---------------------- | ----------- |
| sandbox     | database (materialize) | usage       |
| sandbox     | schema                 | usage       |
| sandbox     | quickstart cluster     | usage       |
| sanxbox     | table (default)        | all         |
| sandbox     | type (default)         | all         |
| sandbox     | connection (default)   | all         |
| sandbox     | secret (default)       | all         |



## Configuration

The following configurations should be considered and applied in the config.tf file prior to applying the template:

| Config                                | Description                                                                                                                                                                                    | Default   |
| ------------------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | --------- |
| team_names                            | A set enumerating the independent teams that will use Materialize. Each will get their own database and segregated entitlements                                                                | analytics |
| create_dev_clusters                   | development resources can be provisioned on a shared dev cluster or can be created ad-hoc as needed by devs. If this is true, this template will provision a shared dev cluster for each team. | false     |
| dev_clusters_size                     | if create_dev_clusters is true, the size to make the dev clusters                                                                                                                              | 3xsmall   |
| dev_clusters_replication_factor       | if create_dev_clusters is true, the number of replicas to provision on each dev cluster                                                                                                        | 0         |
| dev_create_clusters_permission        | Whether devs should be given permission to create their own clusters. If create_dev_clusters is false, this should probably be true.                                                           | true      |
| manage_quickstart_cluster             | The sandbox role requires a quickstart cluster. If there is already one in the system and you don't want to manage it via this template, set to false                                          | true      |
| quickstart_cluster_size               | if manage_quickstart_cluster is true, the size to make the quickstart cluster                                                                                                                  | 3xsmall   |
| quickstart_cluster_replication_factor | if manage_quickstart_cluster is true, the size replication factor to give the quickstart cluster                                                                                               | 0         |
| prod_cluster_size                     | The cluster size for each team's prod cluster to be created                                                                                                                                    | 3xsmall   |
| prod_cluster_replication_factor       | The replication factor for each team's prod cluster                                                                                                                                            | 0         |


## Deployment

- Clone this repo and enter the root directory
- `terraform init` will initialize the terraform state
- double check all the configuration items in config.tf as detailed above
- make sure there are no name clashes in the existing environment
  - no databases with the same names as your teams (configured above)
  - no clusters called _teamname_\_prod already existing
  - no clusters called _teamname_\_dev if you are configuring to create dev clusters
  - no quickstart cluster if you are configuring this template to manage the quickstart cluster
  - no roles called _teamname_\_prodrole, _teamname_devrole, or sandboxrole already in the system
- `terraform apply` will apply the template as configured
  

## Existing objects

This model is designed to be applied to fresh databases / schemas with no objects in them. 
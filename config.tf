variable "team_names" {
    description = "the names of the independent teams that will get their own databases and roles"
    default = ["analytics", "dataeng"]
    type = set(string)
}

variable "create_dev_clusters" {
    description = "true if you want a permenant dev cluster created, rather than developers creating their own dev clusters ad-hoc. default false."
    default = false
    type = bool
}

variable "dev_clusters_size" {
    description = "size of the dedicated per-team dev clusters, if create_dev_clusters is true"
    default = "3xsmall"
    type = string
}

variable "dev_clusters_replication_factor" {
    description = "replication factor of per-team dev clusters, if create_dev_clusters is true"
    default = 0
    type = number
}

variable "dev_create_clusters_permission" {
    description = "true if you want devs to have rights to create clusters for dev"
    default = true
    type = bool
}

variable "manage_quickstart_cluster" {
    description = "true if you want terraform to manage the quickstart cluster. if false, it must exist outside of terraform."
    default = true #false
    type = bool
}

variable "quickstart_cluster_size" {
    description = "if manage_quickstart_cluster true, size to create the quickstart cluster"
    default = "3xsmall"
    type = string
}

variable "quickstart_cluster_replication_factor" {
    description = "if manage_quickstart_cluster true, number of replicas to put on the quickstart cluster. default = 0"
    default = 0
    type = number
}

variable "prod_cluster_size" {
    description = "size to create the quickstart cluster"
    default = "3xsmall"
    type = string
}

variable "prod_cluster_replication_factor" {
    description = "number of replicas to put on the quickstart cluster. default = 0"
    default = 0
    type = number
}

variable "bastion_host" {
  type = string
}

variable "openshift_kubeconfig" {
  type    = string
}

variable "bastion_username" {
  type = string
}

variable "private_ssh_key" {
  type = string
}

variable "playbook_workspace" {
  type    = string
  default = "/tmp"
}

variable "github_target_org" {
  type = string
}

variable "bootstrap_cluster" {
  type    = bool
  default = true
}

variable "github_application_repos" {
  type    = map(any)
  default = {}
}

variable "git_baseurl" {
  type    = string
  default = "https://github.com"
}

variable "github_token" {
  type = string
}

variable "sealed_secret_key_file" {
  type    = string
  default = ""
}

variable "gitops_profile" {
  type    = string
  default = "0-bootstrap/single-cluster"
}

variable "gitops_recipe" {
  type    = string
  default = ""
}

variable "gitops_infra" {
  type    = bool
  default = false
}

variable "rwx_storage_class" {
  type    = string
  default = "ocs-storagecluster-cephfs"
}

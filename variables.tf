variable "bastion_host_public" {
  type = string
}

variable "openshift_kubeconfig" {
  type    = string
  default = ""
}

variable "username" {
  type = string
}

variable "playbook_workspace" {
  type    = string
  default = "/tmp"
}

variable "github_target_org" {
  type = string
}

variable "github_framework_repos" {
  type = map(any)
  default = {
    gitops : {
      source_repo : "multi-tenancy-gitops"
      source_org : "cloud-native-toolkit"
      local : "gitops-0-bootstrap"
      branch : "master"
    }
    infra : {
      source_repo : "multi-tenancy-gitops-infra"
      source_org : "cloud-native-toolkit"
      local : "gitops-1-infra"
      branch : "master"
    }
    services : {
      source_repo : "multi-tenancy-gitops-services"
      source_org : "cloud-native-toolkit"
      local : "gitops-2-services"
      branch : "master"
    }
    apps : {
      source_repo : "multi-tenancy-gitops-apps"
      source_org : "cloud-native-toolkit"
      local : "gitops-3-apps"
      branch : "master"
    }
  }
}

variable "github_application_repos" {
  type = map(any)
}

variable "git_baseurl" {
  type    = string
  default = "https://github.com"
}
variable "github_token" {
  type = string
}

variable "sealed_secret_key_file" {
  type = string
}

variable "gitops_profile" {
  type    = string
  default = "0-bootstrap/single-cluster"
}


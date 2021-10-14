provider "github" {
  token = var.github_token
  owner = var.github_target_org
}

locals {
  private_ssh_key = chomp(file(var.private_ssh_key))
  local_paths     = [for key in keys(var.github_application_repos) : var.github_application_repos[key].local]
  github_framework_repos = {
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
      source_org : "cloud-native-toolkit-demos"
      local : "gitops-3-apps"
      branch : "master"
    }
  }
}

module "github" {
  source = "./github"

  github_target_org        = var.github_target_org
  github_token             = var.github_token
  github_framework_repos   = local.github_framework_repos
  github_application_repos = var.github_application_repos
}



module "gitops_playbook" {
  depends_on = [
    module.github
  ]

  source             = "./ansible"
  playbook_path      = "${path.module}/playbook"
  playbook           = "gitops.yaml"
  username           = var.bastion_username
  private_ssh_key    = local.private_ssh_key
  bastion_host       = var.bastion_host
  playbook_workspace = var.playbook_workspace
  upload_files       = "${path.root}/repositories"
  inventory = templatefile("${path.module}/templates/inventory.tmpl", {
    bastion_host               = var.bastion_host
    username                   = var.bastion_username
    openshift_kubeconfig       = base64encode(file(var.openshift_kubeconfig))
    sealed_secret_key_file     = fileexists(var.sealed_secret_key_file) ? base64encode(file(var.sealed_secret_key_file)) : ""
    playbook_workspace         = var.playbook_workspace
    git_baseurl                = var.git_baseurl
    git_org                    = var.github_target_org
    git_gitops                 = local.github_framework_repos["gitops"].source_repo
    git_gitops_branch          = local.github_framework_repos["gitops"].branch
    git_gitops_infra           = local.github_framework_repos["infra"].source_repo
    git_gitops_infra_branch    = local.github_framework_repos["infra"].branch
    git_gitops_services        = local.github_framework_repos["services"].source_repo
    git_gitops_services_branch = local.github_framework_repos["services"].branch
    git_gitops_apps            = local.github_framework_repos["apps"].source_repo
    git_gitops_apps_branch     = local.github_framework_repos["apps"].branch
    gitops_profile             = var.gitops_profile
    apps_repos_local           = "[${join(",", [for key in keys(var.github_application_repos) : var.github_application_repos[key].local])}]"
    gitops_recipe              = var.gitops_recipe
    gitops_infra               = var.gitops_infra
    rwx_storage_class          = var.rwx_storage_class
  })
}



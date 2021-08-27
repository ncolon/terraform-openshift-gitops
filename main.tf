provider "github" {
  token = var.github_token
  owner = var.github_target_org
}

locals {
  private_ssh_key = chomp(file("~/.ssh/openshift_rsa"))
  local_paths     = [for key in keys(var.github_application_repos) : var.github_application_repos[key].local]
}

module "github" {
  source                   = "./github"
  github_target_org        = var.github_target_org
  github_token             = var.github_token
  github_framework_repos   = var.github_framework_repos
  github_application_repos = var.github_application_repos
}

module "gitops_playbook" {
  depends_on = [
    module.github
  ]

  source              = "./ansible"
  playbook_path       = "${path.module}/playbook"
  playbook            = "gitops.yaml"
  username            = var.username
  private_ssh_key     = local.private_ssh_key
  bastion_host_public = var.bastion_host_public
  playbook_workspace  = var.playbook_workspace
  upload_files        = "${path.root}/repositories"
  inventory = templatefile("${path.module}/templates/inventory.tmpl", {
    bastion_host               = var.bastion_host_public
    username                   = var.username
    openshift_kubeconfig       = var.openshift_kubeconfig
    sealed_secret_key_file     = base64encode(file(var.sealed_secret_key_file))
    playbook_workspace         = var.playbook_workspace
    git_baseurl                = var.git_baseurl
    git_org                    = var.github_target_org
    git_gitops                 = var.github_framework_repos["gitops"].source_repo
    git_gitops_branch          = var.github_framework_repos["gitops"].branch
    git_gitops_infra           = var.github_framework_repos["infra"].source_repo
    git_gitops_infra_branch    = var.github_framework_repos["infra"].branch
    git_gitops_services        = var.github_framework_repos["services"].source_repo
    git_gitops_services_branch = var.github_framework_repos["services"].branch
    git_gitops_apps            = var.github_framework_repos["apps"].source_repo
    git_gitops_apps_branch     = var.github_framework_repos["apps"].branch
    gitops_profile             = var.gitops_profile
    apps_repos_local           = "[${join(",", [for key in keys(var.github_application_repos) : var.github_application_repos[key].local])}]"
  })
}



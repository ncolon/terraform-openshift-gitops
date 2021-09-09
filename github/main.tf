locals {
  repo_local_path = "${path.root}/repositories"
}

resource "github_repository" "framework_repo" {
  for_each    = var.github_framework_repos
  name        = each.value.source_repo
  description = "terraform generated repo from ${each.value.source_org}/${each.value.source_repo}"

  visibility = "public"

  template {
    owner      = each.value.source_org
    repository = each.value.source_repo
  }
}

resource "github_repository" "application_repo" {
  for_each    = var.github_application_repos
  name        = each.value.source_repo
  description = "terraform generated repo from ${each.value.source_org}/${each.value.source_repo}"

  visibility = "public"

  template {
    owner      = each.value.source_org
    repository = each.value.source_repo
  }
}

resource "null_resource" "clone_framework_repo" {
  for_each = var.github_framework_repos

  provisioner "local-exec" {
    command = <<EOF
test -e ${local.repo_local_path} || mkdir ${local.repo_local_path}
git clone ${github_repository.framework_repo[each.key].html_url} ${local.repo_local_path}/${each.value.local}
pushd ${local.repo_local_path}/${each.value.local}
git remote remove origin
git remote add origin https://${var.github_token}@${split("/", var.git_baseurl)[length(split("/", var.git_baseurl)) - 1]}/${var.github_target_org}/${each.value.source_repo}
git push --set-upstream origin master
git checkout ${each.value.branch} || git checkout --track origin/${each.value.branch}
find . -name '*.sh' -exec chmod +x {} \;
popd
EOF
  }

  provisioner "local-exec" {
    command = "rm -rf ./repositories || true"
    when    = destroy
  }
}


resource "null_resource" "clone_application_repo" {
  for_each = var.github_application_repos

  provisioner "local-exec" {
    command = <<EOF
test -e ${local.repo_local_path} || mkdir ${local.repo_local_path}
git clone ${github_repository.application_repo[each.key].html_url} ${local.repo_local_path}/${each.value.local}
pushd ${local.repo_local_path}/${each.value.local}
git remote remove origin
git remote add origin https://${var.github_token}@${split("/", var.git_baseurl)[length(split("/", var.git_baseurl)) - 1]}/${var.github_target_org}/${each.value.source_repo}
git push --set-upstream origin master
git checkout ${each.value.branch} || git checkout --track origin/${each.value.branch}
popd
EOF
  }
}


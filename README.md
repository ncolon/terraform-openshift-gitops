# From Zero to GitOps

## Description

These terraform and ansible scripts will automate the deployment of the GitOps Framework defined in [Cloud Native Toolkit](cloudnativetoolkit.dev). It will fork the main GitOps repositories from CNTK into your github org, deploy the GitOps and Pipelines Operators into your OpenShift Cluster, and bootstrap your cluster with pre-defined [ArgoCD](https://argoproj.github.io/) applications

## Pre-Reqs

1. [Terraform](https://www.terraform.io/downloads.html)
2. [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) on your bastion host
3. SSH enabled on your bastion host. If using a Mac as the bastion host, enable ssh on System Preferences > Sharing > Remote Logging
4. [Passwordless ssh key access](https://linuxize.com/post/how-to-setup-passwordless-ssh-login/) to your bastion host.
5. [A GitHub Org](https://docs.github.com/en/organizations/collaborating-with-groups-in-organizations/creating-a-new-organization-from-scratch)
6. [A GitHub Personal Access Token](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)

	- Token should have `repo`, `admin:repo_hook` and optionally, `delete_repo` to clean up if needed

## Sample .tfvars file

```terraform
github_token      = "ghp_XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX"
github_target_org = "my-github-org"

openshift_kubeconfig = "/path/to/auth/kubeconfig"

bastion_host     = "localhost"
bastion_username = "username"
private_ssh_key  = "~/.ssh/openshift_rsa"

gitops_infra = true
```



## Quick Start

```bash
$ terraform init
$ terraform plan
$ terraform apply
$ export KUBECONFIG=/path/to/auth/kubeconfig
$ oc get route -n openshift-gitops openshift-gitops-cntk-server -o template --template='https://{{.spec.host}}'
https://openshift-gitops-cntk-server-openshift-gitops.apps.clustername.example.com
$ oc extract secrets/openshift-gitops-cntk-cluster --keys=admin.password -n openshift-gitops --to=-
# admin.password
ABCDABCDABCDABCDABCDABCDABCDABCD
```



## Variable Reference

| Variable                  | Description                                                  | Type   | Default                    |
| ------------------------- | ------------------------------------------------------------ | ------ | -------------------------- |
| git_baseurl               | GitHub URL                                                   | string | https://github.com         |
| github_target_org*****    | GitHub Organization.                                         | string | -                          |
| github_token*****         | GitHub Personal Access Token                                 | string | -                          |
| github_application_repos  | GitHub Application/workload repositories                     | map    | {}                         |
| gitops_profile            | Cloud Native Toolkit GitOps Profile. See [here](https://cloudnativetoolkit.dev/adopting/use-cases/gitops/gitops-ibm-cloud-paks/#gitops) for more info. | string | 0-bootstrap/single-cluster |
| gitops_recipe             | [Experimental] Path to GitOps recipe inside the multi-tenancy-gitops repo. ex.:`scripts/bom/ace` | string | -                          |
| gitops_infra              | If set to true, automation will include storage and infrastructure machinesets, as well as deploy OpenShift Container Storage/Data Foundation | bool   | false                      |
| bastion_host*****         | Hostname or IP Address of the bastion host where we will run ansible on | string | -                          |
| bastion_username*****     | Username on `bastion_host`                                   | string | -                          |
| openshift_kubeconfig***** | Path to your cluster's kubeconfig file                       | string | -                          |
| bootstrap_cluster         | When set to `false` we will only configure and populate the gitops repositories in your `github_target_org`.  If `true` we will deploy the ArgoCD applications as well into your cluster | bool   | true                       |
| playbook_workspace        | Path in `bastion_host` where artifacts will be copied to     | string | /tmp                       |
| private_ssh_key*****      | Path to SSH Private Key                                      | string | -                          |
| sealed_secret_key_file    | Path to sealed secret operator key file. **DO NOT CHECK INTO GIT** | string |                            |

***** Required Variable


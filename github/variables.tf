variable "github_token" {
  type = string
}

variable "github_target_org" {
  type = string
}

variable "github_framework_repos" {
  type = map(any)
}

variable "github_application_repos" {
  type = map(any)
}


variable "git_baseurl" {
  type    = string
  default = "https://github.com"
}

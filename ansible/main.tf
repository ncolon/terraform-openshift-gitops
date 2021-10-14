locals {
  basedir            = element(split("/", var.playbook_path), length(split("/", var.playbook_path)) - 1)
  playbook_workspace = var.playbook_workspace != "" ? var.playbook_workspace : "/home/${var.username}"
}

resource "null_resource" "upload_artifacts" {
  count = var.upload_files != "" ? 1 : 0
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.bastion_host
    private_key = var.private_ssh_key
  }

  provisioner "file" {
    source      = var.upload_files
    destination = local.playbook_workspace
  }
}

resource "null_resource" "run_playbook" {
  connection {
    type        = "ssh"
    user        = var.username
    host        = var.bastion_host
    private_key = var.private_ssh_key
  }

  provisioner "file" {
    source      = var.playbook_path
    destination = local.playbook_workspace
  }

  provisioner "file" {
    content     = var.inventory
    destination = "${local.playbook_workspace}/inventory"
  }

  provisioner "file" {
    content     = var.private_ssh_key
    destination = "${local.playbook_workspace}/id_rsa"
  }

  provisioner "remote-exec" {
    inline = [
      "export ANSIBLE_PIPELINING=1",
      "export PATH=/usr/local/bin:$PATH",
      "ansible-playbook -i ${local.playbook_workspace}/inventory ${local.playbook_workspace}/${local.basedir}/${var.playbook}"
    ]
  }
}


resource "time_sleep" "wait_for_ip" {
 depends_on = [azurerm_linux_virtual_machine.amdevops_vm]
 create_duration = "1m"  # Wait for 1 minute to allow Azure to allocate the IP
}

# need to install docker and docker-compose using the ssh key
resource "null_resource" "install_docker" {
  depends_on = [time_sleep.wait_for_ip]
  connection {
    type        = "ssh"
    host        = azurerm_linux_virtual_machine.amdevops_vm.public_ip_address
    user        = var.admin_username
    private_key = file(var.ssh_key_path_private)
  }

  provisioner "file" {
    source      = "scripts/install_docker.sh"
    destination = "/tmp/install_docker.sh"
  }
  
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/install_docker.sh",
      "sudo /tmp/install_docker.sh"
    ]
  }
}
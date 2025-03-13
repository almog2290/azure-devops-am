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
 provisioner "remote-exec" {
   inline = [
    "sudo apt-get update",
    "sudo apt install -y docker.io",
    "sudo apt install -y docker-compose",
    "sudo usermod -aG docker $USER",
    "sudo systemctl enable docker",
    "sudo systemctl start docker",
    "docker --version", 
    "docker-compose --version"
   ]
 }
}
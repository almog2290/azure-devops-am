resource "azurerm_resource_group" "amdevops_rg" {
  name     = "${var.prefix}-rg"
  location = "East US"
}

resource "azurerm_virtual_network" "amdevops_vnet" {
  name                = "${var.prefix}-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.amdevops_rg.location
  resource_group_name = azurerm_resource_group.amdevops_rg.name
}

resource "azurerm_subnet" "amdevops_subnet" {
  name                 = "${var.prefix}-subnet"
  resource_group_name  = azurerm_resource_group.amdevops_rg.name
  virtual_network_name = azurerm_virtual_network.amdevops_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP
resource "azurerm_public_ip" "amdevops_public_ip" {
  name                = "${var.prefix}-public-ip"
  location            = azurerm_resource_group.amdevops_rg.location
  resource_group_name = azurerm_resource_group.amdevops_rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "amdevops_nic" {
  name                = "${var.prefix}-nic"
  location            = azurerm_resource_group.amdevops_rg.location
  resource_group_name = azurerm_resource_group.amdevops_rg.name

  ip_configuration {
    name                          = "amdevops-ipconfig"
    subnet_id                     = azurerm_subnet.amdevops_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.amdevops_public_ip.id
  }
}

resource "azurerm_linux_virtual_machine" "amdevops_vm" {
  name                = "amdevops-vm"
  resource_group_name = azurerm_resource_group.amdevops_rg.name
  location            = azurerm_resource_group.amdevops_rg.location
  size                = "Standard_B1ls"
  admin_username      = "azureuser"
  admin_ssh_key {
    username   = "azureuser"
    public_key = file(var.ssh_key_path)
  }
  
  network_interface_ids = [
    azurerm_network_interface.amdevops_nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}


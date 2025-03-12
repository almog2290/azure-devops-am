import os
from azure.identity import ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.compute import ComputeManagementClient
from azure.mgmt.network.models import PublicIPAddress, NetworkInterface, NetworkInterfaceIPConfiguration
from azure.mgmt.compute.models import VirtualMachine, HardwareProfile, OSProfile, LinuxConfiguration, SshConfiguration, SshPublicKey, NetworkProfile, NetworkInterfaceReference, ImageReference, OSDisk

# Configuration
SUBSCRIPTION_ID = os.getenv("AZURE_SUBSCRIPTION_ID")
CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")
TENANT_ID = os.getenv("AZURE_TENANT_ID")

# Initialize credential with service principal
credential = ClientSecretCredential(
    tenant_id=TENANT_ID,
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET
)

# Set up environment variables
subscription_id = SUBSCRIPTION_ID
resource_group_name = "amdevops-rg"
location = "East US"
prefix = "amdevops"
ssh_key_path = os.path.expanduser("~/.ssh/id_rsa_azure.pub")

# Authenticate
resource_client = ResourceManagementClient(credential, subscription_id)
network_client = NetworkManagementClient(credential, subscription_id)
compute_client = ComputeManagementClient(credential, subscription_id)

# Create Resource Group
resource_client.resource_groups.create_or_update(resource_group_name, {"location": location})

# Create Virtual Network
vnet_params = {
    "location": location,
    "address_space": {"address_prefixes": ["10.0.0.0/16"]}
}
vnet = network_client.virtual_networks.begin_create_or_update(resource_group_name, f"{prefix}-vnet", vnet_params).result()

# Create Subnet
subnet_params = {"address_prefix": "10.0.1.0/24"}
subnet = network_client.subnets.begin_create_or_update(resource_group_name, f"{prefix}-vnet", f"{prefix}-subnet", subnet_params).result()

# Create Public IP
public_ip_params = {
    "location": location,
    "public_ip_allocation_method": "Dynamic",
    "sku": {"name": "Basic"}
}
public_ip = network_client.public_ip_addresses.begin_create_or_update(resource_group_name, f"{prefix}-public-ip", public_ip_params).result()

# Create Network Interface
nic_params = {
    "location": location,
    "ip_configurations": [{
        "name": "amdevops-ipconfig",
        "subnet": {"id": subnet.id},
        "public_ip_address": {"id": public_ip.id},
        "private_ip_allocation_method": "Dynamic"
    }]
}
nic = network_client.network_interfaces.begin_create_or_update(resource_group_name, f"{prefix}-nic", nic_params).result()

# Create Virtual Machine
vm_params = {
    "location": location,
    "hardware_profile": {"vm_size": "Standard_B1ls"},
    "os_profile": {
        "computer_name": "amdevops-vm",
        "admin_username": "azureuser",
        "linux_configuration": {
            "disable_password_authentication": True,
            "ssh": {
                "public_keys": [{
                    "path": f"/home/azureuser/.ssh/authorized_keys",
                    "key_data": open(ssh_key_path).read()
                }]
            }
        }
    },
    "network_profile": {
        "network_interfaces": [{"id": nic.id}]
    },
    "storage_profile": {
        "os_disk": {
            "caching": "ReadWrite",
            "managed_disk": {"storage_account_type": "Standard_LRS"},
            "name": "myosdisk1",
            "create_option": "FromImage"
        },
        "image_reference": {
            "publisher": "Canonical",
            "offer": "0001-com-ubuntu-server-jammy",
            "sku": "22_04-lts",
            "version": "latest"
        }
    }
}
vm = compute_client.virtual_machines.begin_create_or_update(resource_group_name, "amdevops-vm", vm_params).result()

print("Virtual machine created successfully.")
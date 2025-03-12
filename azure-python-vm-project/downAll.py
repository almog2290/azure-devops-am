import os
from azure.identity import ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient
from azure.mgmt.network import NetworkManagementClient
from azure.mgmt.compute import ComputeManagementClient


# Configuration from environment variables
SUBSCRIPTION_ID = os.getenv("AZURE_SUBSCRIPTION_ID")
CLIENT_ID = os.getenv("AZURE_CLIENT_ID")
CLIENT_SECRET = os.getenv("AZURE_CLIENT_SECRET")
TENANT_ID = os.getenv("AZURE_TENANT_ID")

# Validate environment variables
for var in ["AZURE_SUBSCRIPTION_ID", "AZURE_CLIENT_ID", "AZURE_CLIENT_SECRET", "AZURE_TENANT_ID"]:
    if not os.getenv(var):
        raise ValueError(f"Environment variable {var} not set.")

# Set up environment variables
prefix = "amdevops"
RESOURCE_GROUP_NAME = f"{prefix}-rg"
VM_NAME = f"{prefix}-vm"
NIC_NAME = f"{prefix}-nic"
IP_NAME = f"{prefix}-public-ip"
VNET_NAME = f"{prefix}-vnet"
SUBNET_NAME = f"{prefix}-subnet"
LOCATION = "eastus"

# Initialize credential with service principal
credential = ClientSecretCredential(
    tenant_id=TENANT_ID,
    client_id=CLIENT_ID,
    client_secret=CLIENT_SECRET
)

# Initialize clients
resource_client = ResourceManagementClient(credential, SUBSCRIPTION_ID)
network_client = NetworkManagementClient(credential, SUBSCRIPTION_ID)
compute_client = ComputeManagementClient(credential, SUBSCRIPTION_ID)

print("Deleting Azure resources... This may take a few minutes.")

# Step 1: Delete the Virtual Machine
try:
    print(f"Deleting virtual machine {VM_NAME}...")
    compute_client.virtual_machines.begin_delete(RESOURCE_GROUP_NAME, VM_NAME).result()
    print(f"Deleted virtual machine {VM_NAME}")
except Exception as e:
    print(f"Error deleting virtual machine: {e}")

# Step 2: Delete the Network Interface
try:
    print(f"Deleting network interface {NIC_NAME}...")
    network_client.network_interfaces.begin_delete(RESOURCE_GROUP_NAME, NIC_NAME).result()
    print(f"Deleted network interface {NIC_NAME}")
except Exception as e:
    print(f"Error deleting network interface: {e}")

# Step 3: Delete the Public IP Address
try:
    print(f"Deleting public IP address {IP_NAME}...")
    network_client.public_ip_addresses.begin_delete(RESOURCE_GROUP_NAME, IP_NAME).result()
    print(f"Deleted public IP address {IP_NAME}")
except Exception as e:
    print(f"Error deleting public IP address: {e}")

# Step 4: Delete the Virtual Network
try:
    print(f"Deleting virtual network {VNET_NAME}...")
    network_client.virtual_networks.begin_delete(RESOURCE_GROUP_NAME, VNET_NAME).result()
    print(f"Deleted virtual network {VNET_NAME}")
except Exception as e:
    print(f"Error deleting virtual network: {e}")

# Step 5: Delete the Resource Group (cleans up any remaining resources)
try:
    print(f"Deleting resource group {RESOURCE_GROUP_NAME}...")
    resource_client.resource_groups.begin_delete(RESOURCE_GROUP_NAME).result()
    print(f"Deleted resource group {RESOURCE_GROUP_NAME}")
except Exception as e:
    print(f"Error deleting resource group: {e}")

print("All specified resources have been deleted.")
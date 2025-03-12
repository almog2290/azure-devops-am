import os
from azure.identity import ClientSecretCredential
from azure.mgmt.resource import ResourceManagementClient

# Configuration from environment variables
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

# Authenticate
resource_client = ResourceManagementClient(credential, subscription_id)

# Delete Resource Group
resource_client.resource_groups.begin_delete(resource_group_name).result()

print("Resources deleted successfully.")
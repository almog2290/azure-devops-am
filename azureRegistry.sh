#!/bin/bash -e

export TOKEN
export ORG_NAME
export PROJECT_NAME
read -r -p "Enter the name of the resource group: "  resource_group
read -r -p "Enter the registry name: "  registry_name
location="eastus"


# Check if an Azure subscription is already set
current_subscription=$(az account show --query "id" --output tsv 2>/dev/null)
if [[ -z "$current_subscription" ]]; then
    read -s -p "Enter the Azure subscription ID: " subscription_id
    echo ""
    az account set --subscription "$subscription_id"
else
    echo "Using already configured subscription: $current_subscription"
fi

# Configure Azure and Azure DevOps CLI
echo "Configuring Azure DevOps CLI"
az devops configure --defaults \
    organization="https://dev.azure.com/${ORG_NAME}" \
    project="${PROJECT_NAME}"

# Create the resource group
EXISTING_RESOURCE_GROUP=$(az group list --query "[?name=='${resource_group}'].name" -o tsv)
if [ -z "${EXISTING_RESOURCE_GROUP}" ] ; then
    echo "Creating resource group ${resource_group}"
    az group create --name "${resource_group}" --location "${location}"
else
    echo "Resource group ${resource_group} already exists."
fi


# Check if registry already exists , if not create it
EXISTING_REGISTRY=$(az acr list --query "[?name=='${registry_name}'].name" -o tsv)
if [ -z "${EXISTING_REGISTRY}" ] ; then
    echo "Creating registry ${registry_name}"
    az acr create --name "${registry_name}" \
        --resource-group "${resource_group}" \
        --sku Basic \
        --location "${location}"


    echo "Registry ${registry_name} created successfully."
else
    echo "Registry ${registry_name} already exists."
fi
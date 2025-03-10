#!/bin/bash -e

# # Prompt for parameters
# read -r -p "Enter the repository name: " REPO_NAME 
# read -r -p "Enter your token: " TOKEN
# read -r -p "Enter the organization name: " ORG_NAME 
# read -r -p "Enter the project name: " PROJECT_NAME 
# read -r -p "Enter the source folder path: " SRC_FOLDER

export REPO_NAME
export TOKEN
export ORG_NAME
export PROJECT_NAME
export SRC_FOLDER

az devops configure --defaults \
    organization="https://dev.azure.com/${ORG_NAME}" \
    project="${PROJECT_NAME}"

# Check if the repository already exists
if ! az repos list --query "[?name=='${REPO_NAME}']" | grep -q "${REPO_NAME}" ; then
    az repos create --name "${REPO_NAME}"
else
    echo "Repository ${REPO_NAME} already exists."
fi

# Check if the directory already exists
if [ ! -d "${REPO_NAME}" ]; then
    git clone "https://${ORG_NAME}:${TOKEN}@dev.azure.com/${ORG_NAME}/${PROJECT_NAME}/_git/${REPO_NAME}"
else
    echo "Directory ${REPO_NAME} already exists and is not empty."
fi

cp -r "${SRC_FOLDER}"/* "${REPO_NAME}"
cd "${REPO_NAME}"
git add .
git branch -m main
git commit -m "Initial commit"
git push -u origin main

PIPE_ID=$(az pipelines list --output table | grep "${REPO_NAME}" | awk -F " " '{print $1}')
az pipelines run --id "${PIPE_ID}"






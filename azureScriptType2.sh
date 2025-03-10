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
REPO_URL="https://${ORG_NAME}:${TOKEN}@dev.azure.com/${ORG_NAME}/${PROJECT_NAME}/_git/${REPO_NAME}"

az devops configure --defaults \
    organization="https://dev.azure.com/${ORG_NAME}" \
    project="${PROJECT_NAME}"

# Check if the repository already exists
EXISTING_REPO=$(az repos list --query "[?name=='${REPO_NAME}'].name" -o tsv)
if [ -z "${EXISTING_REPO}" ] ; then
    echo "Creating repository ${REPO_NAME}"
    az repos create --name "${REPO_NAME}"
else
    echo "Repository ${REPO_NAME} already exists."
fi


cd "${SRC_FOLDER}"
rm -rf .git
git init
git remote add origin "${REPO_URL}"
git add .
git branch -M main
git commit -m "Initial commit - all project files"
git push -u origin main
echo "push to repo ok !!"
cd ..

az pipelines create --name "$REPO_NAME" \
    --repository "$REPO_NAME" \
    --repository-type tfsgit \
    --branch main \
    --yml-path azure-pipelines.yml \
    --project "$PROJECT_NAME" \
    --organization "https://dev.azure.com/${ORG_NAME}"






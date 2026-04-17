#!/bin/bash

# GA26 Demo - Deployment Script
# This script deploys the .NET application and Bicep infrastructure to Azure

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration
ENVIRONMENT=${1:-dev}
RESOURCE_GROUP_NAME="rg-ga26demo-${ENVIRONMENT}"
LOCATION=${2:-eastus}
DEPLOYMENT_NAME="ga26-deployment-$(date +%s)"

echo -e "${YELLOW}GA26 Demo Deployment Script${NC}"
echo -e "${YELLOW}Environment: ${ENVIRONMENT}${NC}"
echo -e "${YELLOW}Resource Group: ${RESOURCE_GROUP_NAME}${NC}"
echo -e "${YELLOW}Location: ${LOCATION}${NC}"
echo ""

# Check if Azure CLI is installed
if ! command -v az &> /dev/null; then
    echo -e "${RED}Azure CLI is not installed. Please install it first.${NC}"
    exit 1
fi

# Check if logged in to Azure
if ! az account show &> /dev/null; then
    echo -e "${YELLOW}Not logged in to Azure. Running: az login${NC}"
    az login
fi

# Create resource group
echo -e "${GREEN}Creating resource group: ${RESOURCE_GROUP_NAME}${NC}"
az group create \
    --name "${RESOURCE_GROUP_NAME}" \
    --location "${LOCATION}"

# Build .NET application
echo -e "${GREEN}Building .NET application${NC}"
cd "$(dirname "$0")/../src"
dotnet build -c Release

# Publish .NET application
echo -e "${GREEN}Publishing .NET application${NC}"
dotnet publish -c Release -o ./publish

cd "$(dirname "$0")/.."

# Deploy Bicep template
echo -e "${GREEN}Deploying Bicep infrastructure${NC}"
az deployment group create \
    --name "${DEPLOYMENT_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --template-file infra/main.bicep \
    --parameters "infra/parameters.${ENVIRONMENT}.bicepparam"

# Get deployment outputs
echo -e "${GREEN}Getting deployment information${NC}"
APP_URL=$(az deployment group show \
    --name "${DEPLOYMENT_NAME}" \
    --resource-group "${RESOURCE_GROUP_NAME}" \
    --query properties.outputs.appServiceUrl.value \
    --output tsv)

echo ""
echo -e "${GREEN}=== Deployment Complete ===${NC}"
echo -e "Application URL: ${YELLOW}${APP_URL}${NC}"
echo -e "Resource Group: ${YELLOW}${RESOURCE_GROUP_NAME}${NC}"
echo ""
echo "To view deployment details:"
echo "  az deployment group show --name ${DEPLOYMENT_NAME} --resource-group ${RESOURCE_GROUP_NAME}"
echo ""
echo "To view resources:"
echo "  az resource list --resource-group ${RESOURCE_GROUP_NAME}"
echo ""

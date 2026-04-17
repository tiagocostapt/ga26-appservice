#!/usr/bin/env pwsh

<#
.SYNOPSIS
    GA26 Demo - PowerShell Deployment Script
    
.DESCRIPTION
    This script deploys the .NET application and Bicep infrastructure to Azure
    
.PARAMETER Environment
    The deployment environment (dev, prod)
    
.PARAMETER Location
    The Azure region for deployment (default: eastus)
    
.EXAMPLE
    .\deploy.ps1 -Environment dev
    .\deploy.ps1 -Environment prod -Location westus
#>

param(
    [Parameter(Mandatory = $false)]
    [ValidateSet("dev", "prod")]
    [string]$Environment = "dev",
    
    [Parameter(Mandatory = $false)]
    [string]$Location = "eastus"
)

$ErrorActionPreference = "Stop"

# Configuration
$ResourceGroupName = "rg-ga26demo-$Environment"
$DeploymentName = "ga26-deployment-$(Get-Date -Format 'yyyyMMddHHmmss')"
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host "GA26 Demo Deployment Script" -ForegroundColor Yellow
Write-Host "Environment: $Environment" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host "Location: $Location" -ForegroundColor Yellow
Write-Host ""

# Check if Azure CLI is installed
try {
    $null = az --version
}
catch {
    Write-Host "Azure CLI is not installed. Please install it first." -ForegroundColor Red
    exit 1
}

# Check if logged in to Azure
try {
    $null = az account show
}
catch {
    Write-Host "Not logged in to Azure. Running: az login" -ForegroundColor Yellow
    & az login
}

# Create resource group
Write-Host "Creating resource group: $ResourceGroupName" -ForegroundColor Green
& az group create `
    --name $ResourceGroupName `
    --location $Location

# Build .NET application
Write-Host "Building .NET application" -ForegroundColor Green
$srcPath = Join-Path $ScriptPath "src"
Push-Location $srcPath
& dotnet build -c Release

# Publish .NET application
Write-Host "Publishing .NET application" -ForegroundColor Green
& dotnet publish -c Release -o "./publish"
Pop-Location

# Deploy Bicep template
Write-Host "Deploying Bicep infrastructure" -ForegroundColor Green
$infraPath = Join-Path $ScriptPath "infra"
& az deployment group create `
    --name $DeploymentName `
    --resource-group $ResourceGroupName `
    --template-file (Join-Path $infraPath "main.bicep") `
    --parameters (Join-Path $infraPath "parameters.$Environment.bicepparam")

# Get deployment outputs
Write-Host "Getting deployment information" -ForegroundColor Green
$AppUrl = (& az deployment group show `
    --name $DeploymentName `
    --resource-group $ResourceGroupName `
    --query "properties.outputs.appServiceUrl.value" `
    --output tsv)

Write-Host ""
Write-Host "=== Deployment Complete ===" -ForegroundColor Green
Write-Host "Application URL: $AppUrl" -ForegroundColor Yellow
Write-Host "Resource Group: $ResourceGroupName" -ForegroundColor Yellow
Write-Host ""
Write-Host "To view deployment details:"
Write-Host "  az deployment group show --name $DeploymentName --resource-group $ResourceGroupName"
Write-Host ""
Write-Host "To view resources:"
Write-Host "  az resource list --resource-group $ResourceGroupName"
Write-Host ""

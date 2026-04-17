#!/usr/bin/env pwsh

<#
.SYNOPSIS
    GA26 Demo - PowerShell Validation Script
    
.DESCRIPTION
    Checks that all components are in place and valid
#>

$PASSED = 0
$FAILED = 0
$WARNINGS = 0

function Check-File {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path -Path $Path -PathType Leaf) {
        Write-Host "✓ $Description" -ForegroundColor Green
        $script:PASSED++
    }
    else {
        Write-Host "✗ $Description (missing: $Path)" -ForegroundColor Red
        $script:FAILED++
    }
}

function Check-Directory {
    param(
        [string]$Path,
        [string]$Description
    )
    
    if (Test-Path -Path $Path -PathType Container) {
        Write-Host "✓ $Description" -ForegroundColor Green
        $script:PASSED++
    }
    else {
        Write-Host "✗ $Description (missing: $Path)" -ForegroundColor Red
        $script:FAILED++
    }
}

function Check-Command {
    param(
        [string]$Command,
        [string]$Description
    )
    
    if (Get-Command -Name $Command -ErrorAction SilentlyContinue) {
        Write-Host "✓ $Description" -ForegroundColor Green
        $script:PASSED++
    }
    else {
        Write-Host "⚠ $Description (not found: $Command)" -ForegroundColor Yellow
        $script:WARNINGS++
    }
}

Write-Host "GA26 Demo - Validation" -ForegroundColor Yellow
Write-Host ""

# Check .NET Project
Write-Host "📦 .NET Application:" -ForegroundColor Cyan
Check-File "src/GA26Demo.csproj" ".NET Project File"
Check-File "src/Program.cs" "Program Entry Point"

# Check Controllers
Write-Host ""
Write-Host "🎮 Controllers:" -ForegroundColor Cyan
Check-File "src/Controllers/HomeController.cs" "Home Controller"

# Check Views
Write-Host ""
Write-Host "👁️  Views:" -ForegroundColor Cyan
Check-Directory "src/Views" "Views Directory"
Check-File "src/Views/Home/Index.cshtml" "Home View"
Check-File "src/Views/Shared/_Layout.cshtml" "Layout View"
Check-File "src/Views/_ViewStart.cshtml" "ViewStart"
Check-File "src/Views/_ViewImports.cshtml" "ViewImports"

# Check Configuration
Write-Host ""
Write-Host "⚙️  Configuration:" -ForegroundColor Cyan
Check-File "src/appsettings.json" "App Settings"
Check-File "src/appsettings.Production.json" "Production Settings"

# Check Bicep Infrastructure
Write-Host ""
Write-Host "🏗️  Bicep Infrastructure:" -ForegroundColor Cyan
Check-File "infra/main.bicep" "Main Bicep Template"
Check-File "infra/parameters.dev.bicepparam" "Dev Parameters"
Check-File "infra/parameters.prod.bicepparam" "Prod Parameters"

# Check Deployment Scripts
Write-Host ""
Write-Host "🚀 Deployment Scripts:" -ForegroundColor Cyan
Check-File "deploy.sh" "Bash Deployment Script"
Check-File "deploy.ps1" "PowerShell Deployment Script"

# Check Documentation
Write-Host ""
Write-Host "📚 Documentation:" -ForegroundColor Cyan
Check-File "README.md" "README"
Check-File "DEMO_INSTRUCTIONS.md" "Demo Instructions"

# Check Required Tools
Write-Host ""
Write-Host "🔧 Required Tools:" -ForegroundColor Cyan
Check-Command "dotnet" ".NET CLI"
Check-Command "az" "Azure CLI"
Check-Command "git" "Git"

# Check .NET Build
Write-Host ""
Write-Host "🔨 Build Check:" -ForegroundColor Cyan
if (Test-Path "src/GA26Demo.csproj") {
    $content = Get-Content "src/GA26Demo.csproj" -Raw
    
    if ($content -match "net8\.0") {
        Write-Host "✓ .NET 8.0 target" -ForegroundColor Green
        $PASSED++
    }
    else {
        Write-Host "⚠ Not targeting .NET 8.0" -ForegroundColor Yellow
        $WARNINGS++
    }
    
    if ($content -match "Microsoft.ApplicationInsights.AspNetCore") {
        Write-Host "✓ Application Insights Package" -ForegroundColor Green
        $PASSED++
    }
    else {
        Write-Host "✗ Missing Application Insights Package" -ForegroundColor Red
        $FAILED++
    }
}

# Summary
Write-Host ""
Write-Host "════════════════════════════════════════" -ForegroundColor Yellow

if ($FAILED -eq 0 -and $WARNINGS -eq 0) {
    Write-Host "✓ All checks passed!" -ForegroundColor Green
    Write-Host "  Passed: $PASSED" -ForegroundColor Green
    exit 0
}
elseif ($FAILED -eq 0) {
    Write-Host "⚠ Checks passed with warnings" -ForegroundColor Yellow
    Write-Host "  Passed: $PASSED" -ForegroundColor Green
    Write-Host "  Warnings: $WARNINGS" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "⚠️  Warnings:" -ForegroundColor Yellow
    Write-Host "  - Some optional tools are not installed"
    exit 0
}
else {
    Write-Host "✗ Some checks failed" -ForegroundColor Red
    Write-Host "  Passed: $PASSED" -ForegroundColor Green
    Write-Host "  Failed: $FAILED" -ForegroundColor Red
    Write-Host "  Warnings: $WARNINGS" -ForegroundColor Yellow
    exit 1
}

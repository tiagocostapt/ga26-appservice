#!/bin/bash

# GA26 Demo - Validation Script
# Checks that all components are in place and valid

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
WARNINGS=0

check_file() {
    local file=$1
    local description=$2
    
    if [ -f "$file" ]; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description (missing: $file)"
        ((FAILED++))
    fi
}

check_directory() {
    local dir=$1
    local description=$2
    
    if [ -d "$dir" ]; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} $description (missing: $dir)"
        ((FAILED++))
    fi
}

check_command() {
    local cmd=$1
    local description=$2
    
    if command -v "$cmd" &> /dev/null; then
        echo -e "${GREEN}✓${NC} $description"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} $description (not found: $cmd)"
        ((WARNINGS++))
    fi
}

check_syntax() {
    local file=$1
    local description=$2
    local extension="${file##*.}"
    
    if [ "$extension" = "csproj" ]; then
        if grep -q "TargetFramework" "$file"; then
            echo -e "${GREEN}✓${NC} $description"
            ((PASSED++))
        else
            echo -e "${RED}✗${NC} $description (invalid $file)"
            ((FAILED++))
        fi
    fi
}

echo -e "${YELLOW}GA26 Demo - Validation${NC}\n"

# Check .NET Project
echo "📦 .NET Application:"
check_file "src/GA26Demo.csproj" ".NET Project File"
check_file "src/Program.cs" "Program Entry Point"
check_syntax "src/GA26Demo.csproj" "Project File Syntax"

# Check Controllers
echo ""
echo "🎮 Controllers:"
check_file "src/Controllers/HomeController.cs" "Home Controller"

# Check Views
echo ""
echo "👁️  Views:"
check_directory "src/Views" "Views Directory"
check_file "src/Views/Home/Index.cshtml" "Home View"
check_file "src/Views/Shared/_Layout.cshtml" "Layout View"
check_file "src/Views/_ViewStart.cshtml" "ViewStart"
check_file "src/Views/_ViewImports.cshtml" "ViewImports"

# Check Configuration
echo ""
echo "⚙️  Configuration:"
check_file "src/appsettings.json" "App Settings"
check_file "src/appsettings.Production.json" "Production Settings"

# Check Bicep Infrastructure
echo ""
echo "🏗️  Bicep Infrastructure:"
check_file "infra/main.bicep" "Main Bicep Template"
check_file "infra/parameters.dev.bicepparam" "Dev Parameters"
check_file "infra/parameters.prod.bicepparam" "Prod Parameters"

# Check Deployment Scripts
echo ""
echo "🚀 Deployment Scripts:"
check_file "deploy.sh" "Bash Deployment Script"
check_file "deploy.ps1" "PowerShell Deployment Script"

# Check Documentation
echo ""
echo "📚 Documentation:"
check_file "README.md" "README"
check_file "DEMO_INSTRUCTIONS.md" "Demo Instructions"

# Check Required Tools
echo ""
echo "🔧 Required Tools:"
check_command "dotnet" ".NET CLI"
check_command "az" "Azure CLI"
check_command "git" "Git"

# Check .NET Build
echo ""
echo "🔨 Build Check:"
if [ -f "src/GA26Demo.csproj" ]; then
    if grep -q "net10.0" "src/GA26Demo.csproj"; then
        echo -e "${GREEN}✓${NC} .NET 10.0 target"
        ((PASSED++))
    else
        echo -e "${YELLOW}⚠${NC} Not targeting .NET 10.0"
        ((WARNINGS++))
    fi
    
    if grep -q "Microsoft.ApplicationInsights.AspNetCore" "src/GA26Demo.csproj"; then
        echo -e "${GREEN}✓${NC} Application Insights Package"
        ((PASSED++))
    else
        echo -e "${RED}✗${NC} Missing Application Insights Package"
        ((FAILED++))
    fi
fi

# Summary
echo ""
echo -e "${YELLOW}════════════════════════════════════════${NC}"

if [ $FAILED -eq 0 ] && [ $WARNINGS -eq 0 ]; then
    echo -e "${GREEN}✓ All checks passed!${NC}"
    echo -e "  Passed: ${GREEN}$PASSED${NC}"
    exit 0
elif [ $FAILED -eq 0 ]; then
    echo -e "${YELLOW}⚠ Checks passed with warnings${NC}"
    echo -e "  Passed: ${GREEN}$PASSED${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    echo ""
    echo "⚠️  Warnings:"
    echo "  - Some optional tools are not installed"
    echo "  - Install them with: apt install -y azure-cli dotnet-sdk-8.0"
    exit 0
else
    echo -e "${RED}✗ Some checks failed${NC}"
    echo -e "  Passed: ${GREEN}$PASSED${NC}"
    echo -e "  Failed: ${RED}$FAILED${NC}"
    echo -e "  Warnings: ${YELLOW}$WARNINGS${NC}"
    exit 1
fi

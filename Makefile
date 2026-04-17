.PHONY: help build run deploy-dev deploy-prod clean validate publish

# GA26 Demo - Makefile for common tasks

help:
	@echo "GA26 Demo - Available Commands"
	@echo ""
	@echo "  make build          Build the .NET application"
	@echo "  make run            Run the application locally"
	@echo "  make publish        Publish the application for deployment"
	@echo "  make validate       Validate project structure"
	@echo "  make deploy-dev     Deploy to development environment"
	@echo "  make deploy-prod    Deploy to production environment"
	@echo "  make clean          Clean build artifacts"
	@echo "  make help           Show this help message"

build:
	@echo "Building .NET application..."
	cd src && dotnet build

run: build
	@echo "Running application locally..."
	cd src && dotnet run

publish: build
	@echo "Publishing application..."
	cd src && dotnet publish -c Release -o ./publish

validate:
	@echo "Validating project structure..."
	@bash ./validate.sh

deploy-dev: publish
	@echo "Deploying to development environment..."
	@bash ./deploy.sh dev

deploy-prod: publish
	@echo "Deploying to production environment..."
	@bash ./deploy.sh prod

clean:
	@echo "Cleaning build artifacts..."
	cd src && dotnet clean
	rm -rf src/bin src/obj src/publish
	@echo "Done!"

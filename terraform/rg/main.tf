terraform {
  required_version = ">= 1.5"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-tfstate"
    storage_account_name = "sttfstateagtkhe"
    container_name       = "tfstate"
    key                  = "rg.tfstate"
    use_azuread_auth     = true
  }
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "this" {
  name     = var.rg_name
  location = var.region

  tags = {
    environment  = var.environment
    owner        = var.owner
    project      = var.project
    cost-center  = var.cost_center
    created-by   = "github-actions-terraform"
    created-date = formatdate("YYYY-MM-DD", timestamp())
    issue-number = var.issue_number
  }
}

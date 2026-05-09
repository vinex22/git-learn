variable "rg_name" {
  description = "Name of the resource group"
  type        = string

  validation {
    condition     = can(regex("^rg-[a-z0-9]+-[a-z]+$", var.rg_name))
    error_message = "RG name must match pattern rg-<project>-<env>"
  }
}

variable "region" {
  description = "Azure region"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "owner" {
  description = "Owner of the resource group"
  type        = string
}

variable "project" {
  description = "Project name"
  type        = string
}

variable "cost_center" {
  description = "Cost center"
  type        = string
}

variable "issue_number" {
  description = "GitHub issue number that triggered this"
  type        = string
  default     = ""
}

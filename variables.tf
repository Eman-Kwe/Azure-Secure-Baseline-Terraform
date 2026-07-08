variable "subscription_id" {
  description = "Target subscription — az account show --query id -o tsv"
  type        = string
  # no default: forces an explicit choice, prevents deploying to the wrong sub
}

variable "location" {
  description = "Azure region"
  type        = string
  default     = "eastus"
}

variable "environment" {
  description = "dev / staging / prod — drives naming and tags"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "admin_username" {
  description = "VM admin — Azure blocks 'admin'/'root'"
  type        = string
  default     = "azlabadmin"
}

variable "ssh_public_key_path" {
  description = "Public key only — the private key never leaves your machine"
  type        = string
  default     = "~/.ssh/azlab.pub"
}

variable "my_ip" {
  description = "Your public IP (curl -4 ifconfig.me) — sole source allowed for SSH"
  type        = string
}

variable "owner" {
  description = "Owner tag for cost attribution"
  type        = string
  default     = "manuel-armah"
}

variable "vm_size" {
  description = "VM size — must be available to the subscription in var.location (az vm list-skus)"
  type        = string
  default     = "Standard_D2als_v7"
}

variable "vm_principal_id" {
  description = "The VM's managed identity principalId (az vm identity show)"
  type        = string
}


locals {
  # Locals, not a variable: tags are DERIVED from environment so they can never drift from it
  common_tags = {
    environment = var.environment
    owner       = var.owner
    project     = "azure-secure-baseline"
    purpose     = "interview-project"
    managed_by  = "terraform"
  }

  name_prefix = "azlab-${var.environment}"
}


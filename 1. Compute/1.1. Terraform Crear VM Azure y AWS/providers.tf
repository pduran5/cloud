terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0" # Para Azure
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~>5.0" # Para AWS
    }
  }
}

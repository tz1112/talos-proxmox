terraform {
  required_providers {
    proxmox = {
      source = "bpg/proxmox"
      version = "0.69.1"
    }
    talos = {
      source = "siderolabs/talos"
      version = "0.7.0"
    }
  }
}

variable API_URL {
    type = string
}

variable API_TOKEN {
    type = string
}

provider "proxmox" {
  endpoint  = var.API_URL
  api_token = var.API_TOKEN
  insecure  = true 
  ssh {
    agent = true
    username = "terraform"
  }
}
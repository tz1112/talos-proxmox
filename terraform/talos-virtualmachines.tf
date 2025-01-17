variable "proxmox_target_node" {
  type    = string
  default = CHANGE_ME!
}

variable "proxmox_target_tags" {
  type    = list(string)
  default = ["terraform"]
}

resource "proxmox_virtual_environment_vm" "talos_cp_01" {
  name        = "talos-cp-tf-01"
  description = "Managed by Terraform"
  tags        = var.proxmox_target_tags
  node_name   = var.proxmox_target_node
  on_boot     = true
  vm_id       = 500

  cpu {
    cores = 16
    type = "host"
  }

  memory {
    dedicated = 8192
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    # file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_id      = "local:iso/talos-v1.9.2-nocloud-amd64.img"
    file_format  = "raw"
    interface    = "virtio0"
    size         = 50
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  machine = "q35"

  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = "${var.talos_cp_01_ip_addr}/24"
        gateway = var.default_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}

resource "proxmox_virtual_environment_vm" "talos_worker_01" {
  depends_on = [ proxmox_virtual_environment_vm.talos_cp_01 ]
  name        = "talos-worker-tf-01"
  description = "Managed by Terraform"
  tags        = var.proxmox_target_tags
  node_name   = var.proxmox_target_node
  on_boot     = true
  vm_id       = 501

  cpu {
    cores = 16
    type = "host"
  }

  memory {
    dedicated = 76800
  }

  agent {
    enabled = true
  }

  network_device {
    bridge = "vmbr0"
  }

  disk {
    datastore_id = "local-lvm"
    file_id      = "local:iso/talos-v1.9.2-nocloud-amd64.img"
    # file_id      = proxmox_virtual_environment_download_file.talos_nocloud_image.id
    file_format  = "raw"
    interface    = "virtio0"
    size         = 125
  }

  operating_system {
    type = "l26" # Linux Kernel 2.6 - 5.X.
  }

  machine = "q35"

  initialization {
    datastore_id = "local-lvm"
    ip_config {
      ipv4 {
        address = "${var.talos_worker_01_ip_addr}/24"
        gateway = var.default_gateway
      }
      ipv6 {
        address = "dhcp"
      }
    }
  }
}
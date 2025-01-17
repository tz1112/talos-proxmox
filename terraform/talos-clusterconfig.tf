########################################################
# CLUSTER VARIABLES
########################################################

variable "cluster_name" {
  type    = string
  default = "talos-cluster-tf"
}

variable "default_gateway" {
  type    = string
  default = "192.168.8.1"
}

variable "talos_cp_01_ip_addr" {
  type    = string
  default = "192.168.8.250"
}

variable "talos_worker_01_ip_addr" {
  type    = string
  default = "192.168.8.251"
}

########################################################
# CLUSTER SETTINGS
########################################################

# generates random secrets and certificates
resource "talos_machine_secrets" "machine_secrets" {}

# defines general cluster settings such as name, config files and endpoints
data "talos_client_configuration" "talosconfig" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  endpoints            = [var.talos_cp_01_ip_addr]
}

########################################################
# CONTROL PLANE
########################################################

# defines data for the talos controlpane
data "talos_machine_configuration" "machineconfig_cp" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

# resource for the control plane instance
resource "talos_machine_configuration_apply" "cp_config_apply" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_cp_01 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_cp.machine_configuration
  count                       = 1
  node                        = var.talos_cp_01_ip_addr
}

########################################################
# WORKER 
########################################################

# data definition
data "talos_machine_configuration" "machineconfig_worker" {
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_cp_01_ip_addr}:6443"
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.machine_secrets.machine_secrets
}

resource "talos_machine_configuration_apply" "worker_config_apply" {
  depends_on                  = [ proxmox_virtual_environment_vm.talos_worker_01 ]
  client_configuration        = talos_machine_secrets.machine_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.machineconfig_worker.machine_configuration
  count                       = 1
  node                        = var.talos_worker_01_ip_addr
}

########################################################
# TALOS BOOTSTRAP
########################################################


resource "talos_machine_bootstrap" "bootstrap" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

data "talos_cluster_health" "health" {
  depends_on           = [ talos_machine_configuration_apply.cp_config_apply, talos_machine_configuration_apply.worker_config_apply ]
  client_configuration = data.talos_client_configuration.talosconfig.client_configuration
  control_plane_nodes  = [ var.talos_cp_01_ip_addr ]
  worker_nodes         = [ var.talos_worker_01_ip_addr ]
  endpoints            = data.talos_client_configuration.talosconfig.endpoints
}

resource "talos_cluster_kubeconfig" "kubeconfig" {
  depends_on           = [ talos_machine_bootstrap.bootstrap, data.talos_cluster_health.health ]
  client_configuration = talos_machine_secrets.machine_secrets.client_configuration
  node                 = var.talos_cp_01_ip_addr
}

########################################################
# OUTPUT
########################################################

# instead of output vars, we will use localfile resources
# output "talosconfig" {
#   value = data.talos_client_configuration.talosconfig.talos_config
#   sensitive = true
# }

# output "kubeconfig" {
#   value = resource.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
#   sensitive = true
# }

resource "local_file" "talosconfig" {
    content  = data.talos_client_configuration.talosconfig.talos_config
    filename = "talosconfig"
}

resource "local_file" "kubeconfig" {
    content  = resource.talos_cluster_kubeconfig.kubeconfig.kubeconfig_raw
    filename = "kubeconfig"
}
# WriteUp-Terraform

Proxmox API is limited and partly broken. In this example, we used the provide bgp/proxmox, which circumvents this issue using ssh. In order for SSH to work in our semi-productive environment, a new user 'terraform' was created on the proxmox API node. This user has passwordless sudoer rights, and logs in using a dedicated key file.

Use this as a guide: https://olav.ninja/talos-cluster-on-proxmox-with-terraform, fixed some nomeclature and deprecations, optimized file structure for our use case. Store secrets using https://medium.com/@maniyasova.n/manage-secrets-in-terraform-838b433e90c3.

# Instructions:

1. Initialisation

        $ terraform init

2. Plan

        $ terraform plan -var-file secrets.tfvars -out plan.out

3. Deployment

        $ terraform apply plan.out

4. Access outputs

        $ terraform output kubeconfig > kubeconfig // obsolete now, stored in a separate file

4. Destroy

        # terraform destroy -var-file secrets.tfvars



########################
TODO: 

X fix deprecated warning
X store output to files
X cache talos image, test overwrte=false // overwrite false does not work, loading from cache does
X use existing images from proxmox
X ad var for cluster name and description (proxmox-variables)
X rebuild file structure

build bootstrap script in python
deploy as zarf package


Changed talos-cluster:74 from data to resource
Updated talos to v1.9.2, if errors occur with the vms
Changed outputs to ressources to file in cluster:87ff
Removed talos-variables.tf, content copied to talos-cluster.tf (only the variable definitions)
deleted proxmox-clusterconfig.tf, added contetn to providers.tf        
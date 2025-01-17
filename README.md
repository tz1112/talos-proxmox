# talos-vbox
Project for fully automated deployments of kubevirt/cdi on a talos cluster in proxmox. Contains all configuration and asset manifests to run Linux and Windows VMs.

# Sources

Combining instructions from:
1. https://www.talos.dev/v1.9/talos-guides/install/
2. https://kubevirt.io/user-guide/cluster_admin/installation/#installing-kubevirt-on-kubernetes
3. https://kubevirt.io/labs/kubernetes/lab1.html

**BEWARE:** There is a bug in talos v1.9.* in checking SELinux status. Therefore, a custom patch has to be applied to the cluster as specified here: https://github.com/siderolabs/talos/issues/10083

# Instructions:

Deploy CRDs in the following order:

1. local-path-provisioner as default storeageclass (see https://github.com/kubesphere/ks-devops/discussions/30, https://www.talos.dev/v1.9/kubernetes-guides/configuration/local-storage/)
2. kubevirt
3. cdi

Deployment of VM-required PVCs using the cdi-upload-proxy, for example:

```console
virtctl image-upload pvc iso-win10 --image-path=windows10.iso --access-mode=ReadWriteOnce --size=7G --uploadproxy-url=https://localhost:1338 --force-bind --insecure --wait-secs=60 --namespace testnamespace
```

This requires an active upload proxy on the specified IP:PORT, for example using:

```console
kubectl port-forward service/cdi-uploadproxy 1338:443 -n cdi
```

# terraform 

Remember to change var.proxmox_target_node.default to the actual PVE name.



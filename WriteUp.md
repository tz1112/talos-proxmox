# WriteUp

1. Create vms in proxmox

    CONTROL_PLANE   16 Cores, 75gb disk, 16384 ram
    WORKER NODE     16 Cores, 150gb disk, 32768 ram

2. Get IPS

export CONTROL_PLANE_IP=X
export WORKER_IP=Y

3. Generate machine configs

talosctl gen config talos-proxmox-cluster https://$CONTROL_PLANE_IP:6443 --output-dir _out

4. Create control plane node

talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP --file _out/controlplane.yaml

5. Create worker node 

talosctl apply-config --insecure --nodes $WORKER_IP --file _out/worker.yaml

<wait until both are finished installing: controller shows no stage (requires bootstrap, but wait for restart and kubelet HEALTHY), worker shows STATE: RUNNING  >

6. Setup talosctl

    6.1 Create config

        export TALOSCONFIG="_out/talosconfig"
        talosctl config endpoint $CONTROL_PLANE_IP
        talosctl config node $CONTROL_PLANE_IP

    6.2 Set endpoints

        talosctl --talosconfig $TALOSCONFIG config endpoint $CONTROL_PLANE_IP
        talosctl --talosconfig $TALOSCONFIG config node $CONTROL_PLANE_IP

    6.3 Bootstrap cluster

        talosctl --talosconfig $TALOSCONFIG bootstrap

    6.4 Retrieve kubeconfig

        talosctl --talosconfig $TALOSCONFIG kubeconfig .

    6.5 Activate kubeconfig context

        export KUBECONFIG=kubeconfig (use absolute path here)

    6.6 Validate all nodes are shown and ready

        kubectl get nodes


7. Deploy kubevirt

export KUBECONFIG=kubeconfig
export RELEASE=$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-operator.yaml
kubectl apply -f https://github.com/kubevirt/kubevirt/releases/download/${RELEASE}/kubevirt-cr.yaml

<wait until 7 pods are running in ns kubevirt>

8. deploy cdi

export TAG=$(curl -s -w %{redirect_url} https://github.com/kubevirt/containerized-data-importer/releases/latest)
export VERSION=$(echo ${TAG##*/})
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-operator.yaml
kubectl create -f https://github.com/kubevirt/containerized-data-importer/releases/download/$VERSION/cdi-cr.yaml

<wait till all 4 pods in cdi are created>

9. Dpeloy local path provisioner (https://www.talos.dev/v1.9/kubernetes-guides/configuration/local-storage/)

kubectl apply -f local-path-provider-modified.yaml

verify usig:

kubectl get storageclass (should show local-path)

10. Patch SELINUX in talos (v1.9.0 and v1.9.1 only)

    kubectl apply -f selinux-patch.yaml

11. Upload raw image

    10.1 setup proxy to cdi

    kubectl port-forward service/cdi-uploadproxy 1338:443 -n cdi

    10.2 upload image

        kubectl create namespace testnamespace
        
        virtctl image-upload pvc win10base --image-path=win10.qcow2 --access-mode=ReadWriteOnce --size=25G --uploadproxy-url=https://localhost:1338 --force-bind --insecure --wait-secs=60 --namespace testnamespace        
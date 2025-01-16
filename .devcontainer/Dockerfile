FROM ubuntu:latest



# install basic necessities
RUN apt-get update
RUN apt-get install -y vim git apt-transport-https ca-certificates curl gnupg wget software-properties-common

# install kubectl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
RUN chmod +x ./kubectl
RUN mv ./kubectl /usr/local/bin

# install virtctl
RUN curl -LO https://github.com/kubevirt/kubevirt/releases/download/$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)/virtctl-$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)-linux-amd64
RUN mv virtctl-$(curl https://storage.googleapis.com/kubevirt-prow/release/kubevirt/kubevirt/stable.txt)-linux-amd64 virtctl
RUN chmod +x ./virtctl
RUN mv ./virtctl /usr/local/bin

# install terraform (online install broken at time of creation)
COPY terraform /usr/local/bin

USER ubuntu 

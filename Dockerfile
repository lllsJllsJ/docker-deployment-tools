FROM node:17-alpine

RUN apk --update add --no-cache \
  tar \
  python3 \
  py-pip \
  py-setuptools \
  ca-certificates \
  openssl \
  groff \
  less \
  bash \
  curl \
  jq \
  git \
  zip && \
  coreutils && \
  pip install --no-cache-dir --upgrade pip awscli

ENV TERRAFORM_VERSION 1.1.7

RUN wget -O terraform.zip https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip && \
  unzip terraform.zip -d /usr/local/bin && \
  rm -f terraform.zip

ARG KUBERNETES_VERSION=24.2.0
RUN set -exo pipefail && \
    test ${KUBERNETES_VERSION} = 'latest' && kubernetes_version="" || kubernetes_version="==${KUBERNETES_VERSION}" && \
    pip install kubernetes${kubernetes_version}

ARG KUBECTL_VERSION=1.26.0
ARG KUBECTL_BINARY_URL=https://dl.k8s.io/v${KUBECTL_VERSION}/bin/linux/amd64/kubectl
RUN set -x && \
    curl --location --fail --show-error --output /usr/local/bin/kubectl ${KUBECTL_BINARY_URL} && \
    chmod +x /usr/local/bin/kubectl

ARG HELM_PROXY=https://get.helm.sh
ARG HELM_VERSION=3.10.2
RUN set -x && \
    location=${HELM_PROXY}/helm-v${HELM_VERSION}-linux-amd64.tar.gz && \
    archive=/tmp/helm.tar.gz && \
    curl --fail --show-error --output ${archive} ${location} && \
    tar xzf ${archive} --directory /usr/local/bin/ --strip-components 1 --wildcards "**/helm" && \
    rm ${archive}

ENTRYPOINT ["/bin/bash", "-c"]

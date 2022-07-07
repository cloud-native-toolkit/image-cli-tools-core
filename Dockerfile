FROM quay.io/cloudnativetoolkit/terraform:v1.1-v1.5.1

ARG TARGETPLATFORM
ARG OPENSHIFT_CLI_VERSION=4.10

ENV TF_CLI_ARGS_apply="-parallelism=6"

RUN sudo apk add --no-cache \
  ca-certificates \
  perl \
  openvpn \
  && rm -rf /var/cache/apk/*

WORKDIR $GOPATH/bin

COPY src/bin/* /usr/local/bin/

COPY --chown=devops:root src/home/ ${HOME}/

WORKDIR ${HOME}

RUN cat ./image-message >> ./.bashrc-ni

RUN curl -L https://mirror.openshift.com/pub/openshift-v4/$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/clients/ocp/stable-${OPENSHIFT_CLI_VERSION}/openshift-client-linux.tar.gz --output oc-client.tar.gz && \
    mkdir tmp && \
    cd tmp && \
    tar xzf ../oc-client.tar.gz && \
    sudo mv ./oc /usr/local/bin && \
    cd .. && \
    rm -rf tmp && \
    rm oc-client.tar.gz

RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/kubectl" && \
    chmod +x ./kubectl && \
    sudo mv ./kubectl /usr/local/bin

RUN curl -sL -o ./yq3 $(curl -sL https://api.github.com/repos/mikefarah/yq/releases/tags/3.4.1 | jq -r --arg NAME "yq_linux_$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)" '.assets[] | select(.name == $NAME) | .browser_download_url') && \
    chmod +x ./yq3 && \
    sudo mv ./yq3 /usr/bin/yq3

RUN curl -sL -o ./helm.tar.gz https://get.helm.sh/helm-v3.8.2-linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi).tar.gz && \
    tar xzf ./helm.tar.gz linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/helm && \
    sudo mv ./linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/helm /usr/bin/helm && \
    rmdir ./linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi) && \
    rm ./helm.tar.gz

VOLUME /workspaces

ENTRYPOINT ["/bin/bash"]

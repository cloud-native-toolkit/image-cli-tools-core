FROM quay.io/cloudnativetoolkit/terraform:v1.1-v1.3.0

ARG TARGETPLATFORM
ENV OPENSHIFT_CLI_VERSION 4.10

ENV TF_CLI_ARGS="-parallelism=6"

RUN apk add --no-cache \
  unzip \
  sudo \
  shadow \
  openssl \
  ca-certificates \
  perl \
  openvpn \
  && rm -rf /var/cache/apk/*

WORKDIR $GOPATH/bin

COPY src/bin/* /usr/local/bin/

##################################
# User setup
##################################

# Configure sudoers so that sudo can be used without a password
RUN groupadd --force sudo && \
    chmod u+w /etc/sudoers && \
    echo "%sudo   ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

ENV HOME /home/devops

# Create devops user
RUN useradd -u 10000 -g root -G sudo -d ${HOME} -m devops && \
    usermod --password $(echo password | openssl passwd -1 -stdin) devops && \
    mkdir -p /workspaces && \
    chown -R 10000:0 /workspaces

USER devops
WORKDIR ${HOME}

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

RUN wget -q -O ./yq3 $(wget -q -O - https://api.github.com/repos/mikefarah/yq/releases/tags/3.4.1 | jq -r --arg NAME "yq_linux_$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)" '.assets[] | select(.name == $NAME) | .browser_download_url') && \
    chmod +x ./yq3 && \
    sudo mv ./yq3 /usr/bin/yq3

RUN wget -q -O ./helm.tar.gz https://get.helm.sh/helm-v3.8.2-linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi).tar.gz && \
    tar xzf ./helm.tar.gz linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/helm && \
    sudo mv ./linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi)/helm /usr/bin/helm && \
    rmdir ./linux-$(if [[ "$TARGETPLATFORM" == "linux/arm64" ]]; then echo "arm64"; else echo "amd64"; fi) && \
    rm ./helm.tar.gz

VOLUME /workspaces

ENTRYPOINT ["/bin/sh"]

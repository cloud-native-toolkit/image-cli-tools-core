# Cloud-Native Toolkit cli tools

[![Docker Repository on Quay](https://quay.io/repository/cloudnativetoolkit/cli-tools-core/status "Docker Repository on Quay")](https://quay.io/repository/cloudnativetoolkit/cli-tools-core)

This repository builds a Docker image whose container is a client for interacting with different cloud providers (IBM Cloud, AWS, Azure).

The container includes the following tools:

- bash
- terraform cli
- terragrunt cli
- kubectl cli
- oc cli
- git cli
- perl cli
- jq cli
- yq3 cli
- yq4 cli
- helm cli

**Warning: The material contained in this repository has not been thoroughly tested. Proceed with caution.**

## Getting started

### Prerequisites

To run this image, the following tools are required:

- `docker` cli
- `docker` backend - Docker Desktop, colima, etc

### Running the client

Start the client to use it.

- To run the `toolkit` container:

    ```bash
    docker run -itd --name toolkit quay.io/cloudnativetoolkit/cli-tools-core
    ```

Once the client is running in the background, use it by opening a shell in it.

- To use the `toolkit` container, exec shell into it:

    ```bash
    docker exec -it toolkit /bin/bash
    ```

    Your terminal is now in the container. 

Use this shell to run commands using the installed tools and scripts.

When you're finished running commands, to exit the client.

- To leave the `toolkit` container shell, as with any shell:

    ```bash
    exit
    ```

    The container will keep running after you exit its shell.

If the client stops:

- To run the `toolkit` container again:

    ```bash
    docker start toolkit
    ```

The `toolkit` container is just a Docker container, so all [Docker CLI commands](https://docs.docker.com/engine/reference/commandline/cli/) work.

## Container registry

The build automation pushes the built container image to [quay.io/cloudnativetoolkit/cli-tools-core](https://quay.io/cloudnativetoolkit/cli-tools-core)

### Floating tags

The floating image tags use the following convention:

- `latest` - the latest **alpine** version of the image (currently terraform v1.2)
- `alpine` - the latest **alpine** version of the image (currently terraform v1.2)
- `fedora` - the latest **fedora** version of the image (currently terraform v1.2)
- `v1.2` - the latest **alpine** version of the image using terraform v1.2
- `v1.1` - the latest **alpine** version of the image using terraform v1.1
- `v1.0` - the latest **alpine** version of the image using terraform v1.0
- `v1.2-alpine` - the latest **alpine** version of the image using terraform v1.2
- `v1.1-alpine` - the latest **alpine** version of the image using terraform v1.1
- `v1.0-alpine` - the latest **alpine** version of the image using terraform v1.0
- `v1.2-fedora` - the latest **fedora** version of the image using terraform v1.2
- `v1.1-fedora` - the latest **fedora** version of the image using terraform v1.1
- `v1.0-fedora` - the latest **fedora** version of the image using terraform v1.0

### Pinned tags

Each release within the repository corresponds to a pinned image tag that will never be moved to another image. The pinned tags use the following naming convention:

```text
{terraform version}-{release tag}-{base OS image}
```

where:

- `{terraform version}` - is the major and minor version of the terraform cli (e.g. v1.1)
- `{release tag}` - is the release tag for this repository (e.g. v1.0.0)
- `{base OS image}` - is the base OS image (`alpine` or `fedora`)

For example:

```text
v1.1-v1.0.0-alpine
```

## Usage

The image can be used by referring to the image url. The following can be used to run the container image interactively:

```shell
docker run -it quay.io/cloudnativetoolkit/cli-tools-core
```

## Development

To build the default image using the latest version of terraform on alpine, run the following:

```shell
docker build -t cli-tools-core .
```

### Changing terraform versions

The terraform version can be changed by passing the `TERRAFORM_VERSION` as a build arg. For example:

```shell
docker build --build-arg TERRAFORM_VERSION=v1.1 -t cli-tools-core:v1.1 .
```

### Changing base OS versions

The base OS can be changed by using the `Dockerfile-fedora` file. For example:

```shell
docker build -f Dockerfile-fedora -t cli-tools-core:fedora .
```

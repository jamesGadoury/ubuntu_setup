FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV IN_DOCKER=true

RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl wget unzip fontconfig ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/ubuntu_setup
COPY . .

RUN chmod +x initial_setup.bash \
 && /bin/bash initial_setup.bash

WORKDIR /workspace
CMD ["/bin/zsh"]


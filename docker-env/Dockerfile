FROM ubuntu:24.04
ENV DEBIAN_FRONTEND=noninteractive
ENV IN_DOCKER=true
ENV TERM xterm-256color
ENV SHELL /bin/zsh

RUN apt-get update && apt-get install -y --no-install-recommends \
        git curl wget tmux unzip fontconfig ca-certificates \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /opt/
COPY . .

RUN chmod +x run-initial-setup \
 && /bin/bash run-initial-setup

WORKDIR /workspace
CMD ["/bin/zsh"]


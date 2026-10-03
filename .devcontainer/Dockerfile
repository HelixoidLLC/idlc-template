FROM ubuntu:24.04

# Install dependencies
RUN apt update && DEBIAN_FRONTEND=noninteractive apt install -y \
    sudo \
    curl \
    git \
    build-essential \
    clang \
    cmake \
    pkg-config \
    zlib1g \
    zlib1g-dev \
    libssl-dev \
    libffi-dev \
    libyaml-dev \
    libgtk-3-dev \
    libglib2.0-dev \
    libwebkit2gtk-4.1-dev \
    libjavascriptcoregtk-4.1-dev \
    libsoup-3.0-dev \
    libayatana-appindicator3-dev \
    librsvg2-dev

# Add non-privileged user to sudoers
ARG USER=ubuntu
RUN adduser $USER sudo && echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $USER

# Install Mise
RUN curl https://mise.run | sh \
    && echo 'eval "$(~/.local/bin/mise activate bash)"' >> ~/.bashrc

# Install Claude Code CLI
RUN curl -fsSL https://claude.ai/install.sh | bash -s stable

# Install Rust before mise tries to install cargo tools
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --default-toolchain stable \
    && echo 'source $HOME/.cargo/env' >> ~/.bashrc

ENV PATH="/home/${USER}/.cargo/bin:${PATH}"

COPY mise.toml /workspaces/project/mise.toml

WORKDIR /workspaces/project/

# This is a little clunky, but the problem is that the pipx backend in Mise
# requires pipx to be installed. Read here:
#
# https://mise.jdx.dev/dev-tools/backends/pipx.html
#
# So this command does this:
# 1. Setup Mise project.
# 2. Install Python.
# 3. Install pipx with the Mise Python version.
# 4. Install rest of tools.
ENV PATH="/home/${USER}/.local/bin:/home/${USER}/.local/share/mise/shims:/home/${USER}/.cargo/bin:${PATH}"
RUN mise settings add idiomatic_version_file_enable_tools "[]" \
    && mise trust \
    && mise install python \
    && pip install --user pipx \
    && mise install

# Cache bun dependencies for faster rebuilds
COPY package.json bun.lockb* /workspaces/project/
RUN bun install --frozen-lockfile || true

# Tool versions are managed with Mise in the Docker container to avoid
# maintaining version numbers in both the Dockerfile and mise.toml file.

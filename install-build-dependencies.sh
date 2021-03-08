#!/bin/bash

set -eExo pipefail

sudo apt-get update -y

# Install LLVM/Clang tool chain
sudo DEBIAN_FRONTEND="noninteractive" apt-get install -y \
  xz-utils \
  wget \
  ca-certificates \
  build-essential \
  curl \
  gcc \
  git \
  direnv \
  cscope \
  #xsel

LLVM_VERSION=10.0.0
LLVM_TARGET=x86_64-linux-gnu-ubuntu-18.04
LLVM_BASE_URL=http://releases.llvm.org/${LLVM_VERSION}
LLVM_ARCHIVE=clang+llvm-${LLVM_VERSION}-${LLVM_TARGET}
LLVM_URL=${LLVM_BASE_URL}/${LLVM_ARCHIVE}.tar.xz
LLVM_DIRECTORY=/usr/lib/llvm

wget ${LLVM_URL}
tar -xJf ${LLVM_ARCHIVE}.tar.xz -C /tmp
sudo mkdir -p ${LLVM_DIRECTORY}
sudo mv /tmp/${LLVM_ARCHIVE}/* ${LLVM_DIRECTORY}/
rm -f ${LLVM_ARCHIVE}.tar.xz
echo "${LLVM_DIRECTORY}/lib" | sudo tee /etc/ld.so.conf.d/llvm.conf
sudo ldconfig

# Install bazel
BAZELISK_VERSION="v1.0"
BAZELISK_BASE_URL="https://github.com/bazelbuild/bazelisk/releases/download"
BAZELISK_BIN="bazelisk-linux-amd64"
BAZELISK_URL="${BAZELISK_BASE_URL}/${BAZELISK_VERSION}/${BAZELISK_BIN}"
wget ${BAZELISK_URL}
chmod +x ${BAZELISK_BIN}
sudo mv ${BAZELISK_BIN} /usr/local/bin/bazel

# Install dependencies for building istio/proxy & envoy
sudo DEBIAN_FRONTEND="noninteractive"  apt-get install -y --no-install-recommends \
  autoconf \
  automake \
  cmake \
  libtool \
  ninja-build \
  python \
  unzip \
  virtualenv

# Install Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository \
    "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
    $(lsb_release -cs) \
    stable"
sudo apt-get update -y && \
    sudo DEBIAN_FRONTEND="noninteractive" apt-get install -y docker-ce

# Add user
sudo addgroup --gid 2001 $USERNAME
sudo adduser --gecos "" --home /home/$USERNAME --disabled-password \
  --shell /bin/bash --uid 2001 --gid 2001 $USERNAME
sudo mkdir -p /home/$USERNAME/.ssh
sudo chmod 700 /home/$USERNAME/.ssh
echo "$SSH_PUBLIC_KEY" | sudo tee /home/$USERNAME/.ssh/authorized_keys
sudo chmod 644 /home/$USERNAME/.ssh/authorized_keys
sudo chown -R $USERNAME:$USERNAME /home/$USERNAME/

# Add $USERNAME user to sudoers list
echo "$USERNAME ALL=(ALL) NOPASSWD:ALL" > 100-$USERNAME
sudo chown root:root 100-$USERNAME
sudo chmod 0440 100-$USERNAME
sudo mv 100-$USERNAME /etc/sudoers.d/

# Add ubuntu & $USERNAME user to docker group
sudo usermod -aG docker ubuntu
sudo usermod -aG docker $USERNAME
sudo systemctl enable docker

# Install Golang tools
GO_PKG=go1.13.6.linux-amd64.tar.gz
curl -o /tmp/$GO_PKG https://dl.google.com/go/$GO_PKG
sudo tar -C /usr/local -xzf /tmp/$GO_PKG

# Set PATH to include Go binary
echo 'PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/go/bin:/usr/lib/llvm/bin"' | sudo tee /etc/environment

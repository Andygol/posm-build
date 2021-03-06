#!/bin/bash

deploy_base_ubuntu() {
  apt-get purge -y \
    whoopsie

  apt-get update
  apt-get -y upgrade
  apt-get install --no-install-recommends -y \
    avahi-daemon \
    avahi-autoipd \
    ca-certificates \
    curl \
    git \
    ssh \
    tmux \
    vim \
    moreutils

  curl -L https://github.com/stedolan/jq/releases/download/jq-1.5/jq-linux64 -o /usr/local/bin/jq
  chmod +x /usr/local/bin/jq
}

deploy_base_rhel() {
  yum install -y \
    curl \
    git \
    openssh \
    vim-enhanced
}

deploy base

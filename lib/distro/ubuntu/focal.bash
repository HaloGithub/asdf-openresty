#!/usr/bin/env bash

set -euo pipefail

ubuntu_focal_pre() {
    RESTY_ADD_PACKAGE_BUILDDEPS=$1
    RESTY_ADD_PACKAGE_RUNDEPS=$2
    # Copy from https://github.com/openresty/docker-openresty/blob/master/focal/Dockerfile#L85-L102
    DEBIAN_FRONTEND=noninteractive sudo apt-get update \
    && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y --no-install-recommends \
        build-essential \
        ca-certificates \
        curl \
        gettext-base \
        libgd-dev \
        libgeoip-dev \
        libncurses5-dev \
        libperl-dev \
        libreadline-dev \
        libxslt1-dev \
        make \
        perl \
        unzip \
        zlib1g-dev \
        "$RESTY_ADD_PACKAGE_BUILDDEPS" \
        "$RESTY_ADD_PACKAGE_RUNDEPS"
}

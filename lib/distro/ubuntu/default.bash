#!/usr/bin/env bash

set -euo pipefail

os_init() {
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


os_post_make() {
    # Copy from https://github.com/openresty/docker-openresty/blob/master/focal/Dockerfile#L161
    if [ -n "$RESTY_EVAL_POST_MAKE" ]; then
        eval "$RESTY_EVAL_POST_MAKE";
    fi

    # Copy from https://github.com/openresty/docker-openresty/blob/master/focal/Dockerfile#L163
    if [ -n "$RESTY_ADD_PACKAGE_BUILDDEPS" ]; then
        DEBIAN_FRONTEND=noninteractive sudo apt-get remove -y --purge "$RESTY_ADD_PACKAGE_BUILDDEPS" ;
    fi

    # Copy from https://github.com/openresty/docker-openresty/blob/master/focal/Dockerfile#L164
    DEBIAN_FRONTEND=noninteractive sudo apt-get autoremove -y
}

#!/usr/bin/env bash

set -euo pipefail

os_init() {
    # Remove below options for MacOS:
    #   1. --with-file-aio: Due to "no supported file AIO was found" error
    export RESTY_CONFIG_OPTIONS="\
        --with-compat \
        --with-http_addition_module \
        --with-http_auth_request_module \
        --with-http_dav_module \
        --with-http_flv_module \
        --with-http_geoip_module=dynamic \
        --with-http_gunzip_module \
        --with-http_gzip_static_module \
        --with-http_image_filter_module=dynamic \
        --with-http_mp4_module \
        --with-http_random_index_module \
        --with-http_realip_module \
        --with-http_secure_link_module \
        --with-http_slice_module \
        --with-http_ssl_module \
        --with-http_stub_status_module \
        --with-http_sub_module \
        --with-http_v2_module \
        --with-http_xslt_module=dynamic \
        --with-ipv6 \
        --with-mail \
        --with-mail_ssl_module \
        --with-md5-asm \
        --with-pcre-jit \
        --with-sha1-asm \
        --with-stream \
        --with-stream_ssl_module \
        --with-threads \
        "
    brew install libgeoip
}


os_post_make() {
    # Copy from https://github.com/openresty/docker-openresty/blob/master/focal/Dockerfile#L161
    if [ -n "$RESTY_EVAL_POST_MAKE" ]; then
        eval "$RESTY_EVAL_POST_MAKE";
    fi
}

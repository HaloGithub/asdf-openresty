#!/usr/bin/env bash
# shellcheck disable=SC2034

set -eu -o pipefail

RESTY_VERSION="1.19.9.1"
RESTY_LUAROCKS_VERSION="3.8.0"
RESTY_OPENSSL_VERSION="1.1.1n"
RESTY_OPENSSL_PATCH_VERSION="1.1.1f"
RESTY_OPENSSL_URL_BASE="https://www.openssl.org/source"
RESTY_PCRE_VERSION="8.44"
RESTY_PCRE_SHA256="aecafd4af3bd0f3935721af77b889d9024b2e01d96b58471bd91a3063fb47728"
RESTY_J="1"
RESTY_CONFIG_OPTIONS="\
    --with-compat \
    --with-file-aio \
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
RESTY_CONFIG_OPTIONS_MORE=""
RESTY_LUAJIT_OPTIONS="--with-luajit-xcflags='-DLUAJIT_NUMMODE=2 -DLUAJIT_ENABLE_LUA52COMPAT'"

RESTY_ADD_PACKAGE_BUILDDEPS=""
RESTY_ADD_PACKAGE_RUNDEPS=""
RESTY_EVAL_PRE_CONFIGURE=""
RESTY_EVAL_POST_MAKE=""

# These are not intended to be user-specified
_RESTY_CONFIG_DEPS="--with-pcre \
    --with-cc-opt='-DNGX_LUA_ABORT_AT_PANIC -I/usr/local/openresty/pcre/include -I/usr/local/openresty/openssl/include' \
    --with-ld-opt='-L/usr/local/openresty/pcre/lib -L/usr/local/openresty/openssl/lib -Wl,-rpath,/usr/local/openresty/pcre/lib:/usr/local/openresty/openssl/lib' \
    "

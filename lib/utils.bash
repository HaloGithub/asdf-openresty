#!/usr/bin/env bash

set -euo pipefail

if [ "${#BASH_SOURCE[@]}" -gt 0 ];
then
    current_script_path="$(realpath "${BASH_SOURCE[0]}")"
else
    current_script_path="$(realpath "$0")"
fi
plugin_dir=$(realpath "$(dirname "$(dirname "$current_script_path")")")


GH_REPO="https://github.com/openresty/openresty"
TOOL_NAME="openresty"


fail() {
  echo -e "asdf-$TOOL_NAME: $*"
  exit 1
}


get_os_distro() {
    lsb_release -i | sed 's/Distributor ID:\s*//' | tr '[:upper:]' '[:lower:]'
}


get_os_code() {
    lsb_release -c | sed 's/Codename:\s*//'
}


sort_versions() {
  sed 'h; s/[+-]/./g; s/.p\([[:digit:]]\)/.z\1/; s/$/.z/; G; s/\n/ /' |
    LC_ALL=C sort -t. -k 1,1 -k 2,2n -k 3,3n -k 4,4n -k 5,5n | awk '{print $2}'
}


list_github_tags() {
  git ls-remote --tags --refs "$GH_REPO" |
    grep -o 'refs/tags/.*' | cut -d/ -f3- |
    sed 's/^v//' # NOTE: You might want to adapt this sed to remove non-version strings from tags
}


list_all_versions() {
  # TODO: Adapt this. By default we simply list the tag names from GitHub releases.
  # Change this function if <YOUR TOOL> has other means of determining installable versions.
  list_github_tags
}


download_openssl() {
    download_path=$1
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path" \
    && curl -fSL "$RESTY_OPENSSL_URL_BASE/openssl-$RESTY_OPENSSL_VERSION.tar.gz" -o "openssl-$RESTY_OPENSSL_VERSION.tar.gz" \
    && tar xzf "openssl-$RESTY_OPENSSL_VERSION.tar.gz"
}


install_openssl() {
    download_path=$1 \
    install_path=$2 \
    make_j=$3
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path/openssl-$RESTY_OPENSSL_VERSION" \
    && if [ "$(echo $RESTY_OPENSSL_VERSION | cut -c 1-5)" = "1.1.1" ] ; then \
        echo 'patching OpenSSL 1.1.1 for OpenResty' \
        && curl -s "https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-$RESTY_OPENSSL_PATCH_VERSION-sess_set_get_cb_yield.patch" | patch -p1 ; \
    fi \
    && if [ "$(echo $RESTY_OPENSSL_VERSION | cut -c 1-5)" = "1.1.0" ] ; then \
        echo 'patching OpenSSL 1.1.0 for OpenResty' \
        && curl -s https://raw.githubusercontent.com/openresty/openresty/ed328977028c3ec3033bc25873ee360056e247cd/patches/openssl-1.1.0j-parallel_build_fix.patch | patch -p1 \
        && curl -s "https://raw.githubusercontent.com/openresty/openresty/master/patches/openssl-$RESTY_OPENSSL_PATCH_VERSION-sess_set_get_cb_yield.patch" | patch -p1 ; \
    fi \
    && ./config \
      no-threads shared zlib -g \
      enable-ssl3 enable-ssl3-method \
      --prefix="$install_path/openssl" \
      --libdir=lib \
      -Wl,-rpath,"$install_path/openssl/lib" \
    && make -j"$make_j" \
    && make -j"$make_j" install_sw
}


download_pcre() {
    download_path=$1
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path" \
    && curl -fSL "https://downloads.sourceforge.net/project/pcre/pcre/$RESTY_PCRE_VERSION/pcre-$RESTY_PCRE_VERSION.tar.gz" -o "pcre-$RESTY_PCRE_VERSION.tar.gz" \
    && echo "$RESTY_PCRE_SHA256  pcre-$RESTY_PCRE_VERSION.tar.gz" | shasum -a 256 --check \
    && tar xzf pcre-$RESTY_PCRE_VERSION.tar.gz
}


install_pcre() {
    download_path=$1 \
    install_path=$2 \
    make_j=$3
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path/pcre-$RESTY_PCRE_VERSION" \
    && ./configure \
        --prefix="$install_path/pcre" \
        --disable-cpp \
        --enable-jit \
        --enable-utf \
        --enable-unicode-properties \
    && make -j"$make_j" \
    && make -j"$make_j" install
}


download_openresty() {
    download_path=$1 \
    install_version=$2
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path" \
    && curl -fSL "https://openresty.org/download/openresty-$install_version.tar.gz" -o "openresty-$install_version.tar.gz" \
    && tar xzf "openresty-$install_version.tar.gz"
}


install_openresty() {
    download_path=$1 \
    install_path=$2 \
    make_j=$3 \
    install_version=$4
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path/openresty-$install_version" \
    && eval ./configure -j"$make_j" \
        "$_RESTY_CONFIG_DEPS" \
        "$RESTY_CONFIG_OPTIONS" \
        "$RESTY_CONFIG_OPTIONS_MORE" \
        "$RESTY_LUAJIT_OPTIONS" \
        --prefix="$install_path/openresty" \
        --with-openssl="$download_path/openssl-$RESTY_OPENSSL_VERSION" \
        --with-pcre="$download_path/pcre-$RESTY_PCRE_VERSION" \
    && make -j"$make_j" \
    && make -j"$make_j" install
}


download_luarocks() {
    download_path=$1
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path" \
    && curl -fSL "https://luarocks.github.io/luarocks/releases/luarocks-$RESTY_LUAROCKS_VERSION.tar.gz" -o "luarocks-$RESTY_LUAROCKS_VERSION.tar.gz" \
    && tar xzf "luarocks-$RESTY_LUAROCKS_VERSION.tar.gz"
}


install_luarocks() {
    download_path=$1 \
    install_path=$2 \
    make_j=$3
    # shellcheck source=lib/vars.bash
    source "$plugin_dir/lib/vars.bash" \
    && cd "$download_path/luarocks-$RESTY_LUAROCKS_VERSION" \
    && ./configure \
        --prefix="$install_path/luarocks" \
        --with-lua="$install_path/openresty/luajit" \
        --lua-suffix=jit-2.1.0-beta3 \
        --with-lua-include="$install_path/openresty/luajit/include/luajit-2.1" \
    && make build \
    && make install
}

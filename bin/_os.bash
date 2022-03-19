#!/usr/bin/env bash

set -euo pipefail


if [ "${#BASH_SOURCE[@]}" -gt 0 ];
then
    current_script_path="${BASH_SOURCE[0]}"
else
    current_script_path="$0"
fi
current_script_dir="$(dirname "$current_script_path")"


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


uname=$(uname)
case "$uname" in
    (*Linux*)
        plugin_dir=$(realpath "$(dirname "$current_script_dir")")

        # shellcheck source=lib/vars.bash
        source "$plugin_dir/lib/vars.bash"

        case $(get_os_distro) in
            ubuntu)
                case $(get_os_code) in
                    focal)
                        source "$plugin_dir/lib/distro/ubuntu/focal.bash"
                        ubuntu_focal_pre "$RESTY_ADD_PACKAGE_BUILDDEPS" "$RESTY_ADD_PACKAGE_RUNDEPS"
                        ;;
                esac
                ;;

            *)
                fail "Unsupported os distro: $(get_os_distro)"
                ;;
        esac
        ;;
    (*Darwin*)
        brew install coreutils

        plugin_dir=$(realpath "$(dirname "$current_script_dir")")

        # shellcheck source=lib/vars.bash
        source "$plugin_dir/lib/vars.bash"

        # Remove below options for MacOS:
        #   1. --with-file-aio: no supported file AIO was found
        #   2. --with-http_geoip_module=dynamic: the GeoIP module requires the GeoIP library.
        RESTY_CONFIG_OPTIONS="\
            --with-compat \
            --with-http_addition_module \
            --with-http_auth_request_module \
            --with-http_dav_module \
            --with-http_flv_module \
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
        ;;
    (*)
        fail "Unsupported platform: $uname"
        exit 2
        ;;
esac;

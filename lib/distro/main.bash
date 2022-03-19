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
    echo -e "asdf-openresty: $*"
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
                        # shellcheck source=lib/distro/ubuntu/focal.bash
                        source "$plugin_dir/lib/distro/ubuntu/focal.bash"
                        ubuntu_focal_pre
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

        # realpath only works after install coreutils package.
        plugin_dir=$(realpath "$(dirname "$current_script_dir")")

        # shellcheck source=lib/vars.bash
        source "$plugin_dir/lib/vars.bash"

        # shellcheck source=lib/distro/darwin/default.bash
        source "$plugin_dir/lib/distro/darwin/default.bash"
        darwin_default_pre
        ;;
    (*)
        fail "Unsupported platform: $uname"
        exit 2
        ;;
esac;

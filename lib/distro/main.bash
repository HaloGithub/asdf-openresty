#!/usr/bin/env bash

set -euo pipefail


if [ "${#BASH_SOURCE[@]}" -gt 0 ]; then
    main_script_path="${BASH_SOURCE[0]}"
else
    main_script_path="$0"
fi
main_script_dir="$(dirname "$main_script_path")"


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
        # shellcheck source=lib/vars.bash
        source "$main_script_dir/../vars.bash"

        case $(get_os_distro) in
            ubuntu)
                # shellcheck source=lib/distro/ubuntu/default.bash
                source "$main_script_dir/ubuntu/default.bash"
                ;;
            *)
                fail "Unsupported os distro: $(get_os_distro)"
                ;;
        esac
        ;;
    (*Darwin*)
        brew install coreutils

        # shellcheck source=lib/vars.bash
        source "$main_script_dir/../vars.bash"

        # shellcheck source=lib/distro/darwin/default.bash
        source "$main_script_dir/darwin/default.bash"
        ;;
    (*)
        fail "Unsupported platform: $uname"
        exit 2
        ;;
esac;

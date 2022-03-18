#!/usr/bin/env bash


fail() {
    echo -e "asdf-$TOOL_NAME: $*"
    exit 1
}


realpath_cmd() {
    uname=$(uname);
    case "$uname" in
    (*Linux*)
        realpath_cmd="realpath"
        ;;
    (*Darwin*)
        brew install coreutils
        realpath_cmd="grealpath"
        ;;
    (*)
        fail "Unsupported platform: $uname"
        exit 2
        ;;
    esac;
    echo "$realpath_cmd"
}

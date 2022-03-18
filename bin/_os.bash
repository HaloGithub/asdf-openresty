#!/usr/bin/env bash


fail() {
    echo -e "asdf-$TOOL_NAME: $*"
    exit 1
}


uname=$(uname)
case "$uname" in
    (*Linux*)
        ;;
    (*Darwin*)
        brew install coreutils
        ;;
    (*)
        fail "Unsupported platform: $uname"
        exit 2
        ;;
esac;

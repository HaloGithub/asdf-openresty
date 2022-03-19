asdf-openresty
==============

[OpenResty](https://openresty.org/en/) plugin for [asdf](https://github.com/asdf-vm/asdf) version manager.

## Install

```shell
asdf plugin-add openresty https://github.com/HaloGithub/asdf-openresty.git
```

## Linting

```shell
docker run --rm -v $(pwd):/mnt koalaman/shellcheck --format=gcc --external-sources bin/* lib/**/*.bash
```

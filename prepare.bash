#!/bin/bash -eux

url="$1"
dir="${url##*/}"
file="$dir.cr"

mkdir "$dir"
pushd "$dir"
touch "$file"
rmine "$PWD/$file"
/home/linuxbrew/.linuxbrew/bin/oj d "$url"
popd

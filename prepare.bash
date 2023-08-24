#!/bin/bash -eux

url="$1"
task="${url##*/}"
dir="src/$task"
file="$task.cr"

mkdir -p "$dir"
pushd "$dir"
touch "$file"
rmine "$PWD/$file"
/home/linuxbrew/.linuxbrew/bin/oj d "$url"
popd

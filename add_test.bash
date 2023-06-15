#!/bin/bash -eux

latest_file=$(find "$PWD/test" "$PWD" -name 'handmade-*.in' | sort -V | tail -n1)
file_dir=${latest_file%/*}
index=$(echo "$latest_file" | sed -E 's/^.*handmade-([0-9]+)\.in/\1/g')
next_index=$(( ${index:-0} + 1 ))

out_file="$file_dir/handmade-${next_index}.out"
in_file="$file_dir/handmade-${next_index}.in"

touch "$out_file" "$in_file"
rmine "$out_file" "$in_file"

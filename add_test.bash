#!/bin/bash -eux

last=$(find "$PWD/test" -name 'handmade-*.in' | sort -V | tail -n1)
index=$(echo "$last" | sed -E 's/^.*handmade-([0-9]+)\.in/\1/g')
next_index=$(( ${index:-0} + 1 ))

out_file="$PWD/test/handmade-${next_index}.out"
in_file="$PWD/test/handmade-${next_index}.in"

touch "$out_file" "$in_file"
rmine "$out_file" "$in_file"

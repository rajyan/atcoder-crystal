#!/bin/bash -eux

test_dir=$(find "$PWD/test" "$PWD" -name '*.in' | head -1 | xargs dirname)
latest_file=$(find "$test_dir" -name 'handmade-*.in' | sort -V | tail -n1)
index=$(echo "$latest_file" | sed -E 's/^.*-([0-9]+)\.in/\1/g')
next_index=$(( ${index:-0} + 1 ))

out_file="$test_dir/handmade-$next_index.out"
in_file="$test_dir/handmade-$next_index.in"

touch "$out_file" "$in_file"
rmine "$out_file" "$in_file"

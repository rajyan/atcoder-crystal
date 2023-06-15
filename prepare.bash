#!/bin/bash -eux

url="$1"
dir="${url##*/}"
file="$dir.cr"

mkdir "$dir"
pushd "$dir"
touch "$file"
cat <<EOF >> "$file"
macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

EOF
rmine "$PWD/$file"
/home/linuxbrew/.linuxbrew/bin/oj d "$url"
popd
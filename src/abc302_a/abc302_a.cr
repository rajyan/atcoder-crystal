macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

a, b = read_line.split.map(&.to_i64)
puts (a - 1)//b + 1

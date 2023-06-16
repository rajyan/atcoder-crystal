macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

n, m = read_line.split.map(&.to_i)
s = Array.new(n) { read_line }

s.each_permutation do |t|
  next unless n.pred.times.all? { |i| m.times.count { |j| t[i][j] != t[i + 1][j] } <= 1 }
  puts "Yes"
  exit
end

puts "No"

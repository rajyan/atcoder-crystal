macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

n, m, d = read_line.split.map(&.to_i64)
a = read_line.split.map(&.to_i64).sort.reverse
b = read_line.split.map(&.to_i64).sort
b_rev = b.reverse

ans = -1
a.each do |a_|
  l = b.bsearch { |b_| b_ >= a_ - d }
  r = b_rev.bsearch { |b_| b_ <= a_ + d }
  ans = [ans, l + a_].max if !l.nil? && (l - a_).abs <= d
  ans = [ans, r + a_].max if !r.nil? && (r - a_).abs <= d
end

puts ans

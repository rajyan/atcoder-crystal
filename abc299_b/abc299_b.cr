macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

n, t = read_line.split.map(&.to_i)
c = read_line.split.map(&.to_i)
r = read_line.split.map(&.to_i)

cr = Array.new(n) { |i| {c[i], r[i]} }
a1 = cr.select { |(c, r)| c == t }
a2 = cr.select { |(c, r)| c == cr.first[0] }

assert(!a1.empty? || !a2.empty?)

max = a1.empty? ? a2.max_by { |(_, r)| r } : a1.max_by { |(_, r)| r }
ans = cr.index(max)
assert(ans)
puts ans + 1

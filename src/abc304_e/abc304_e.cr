require "atcoder/dsu"

n, m = read_line.split.map(&.to_i)
dsu = AtCoder::DSU.new(n)
m.times do
  u, v = read_line.split.map(&.to_i.pred)
  dsu.merge(u, v)
end

set = Set({Int64, Int64}).new
read_line.to_i.times do
  x, y = read_line.split.map(&.to_i64.pred)
  lx, ly = dsu.leader(x), dsu.leader(y)
  set << {lx, ly}
  set << {ly, lx}
end

read_line.to_i.times do
  p, q = read_line.split.map(&.to_i.pred)
  puts set.includes?({dsu.leader(p), dsu.leader(q)}) ? :No : :Yes
end

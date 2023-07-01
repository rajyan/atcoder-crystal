n, m = read_line.split.map(&.to_i)
c = read_line.split
d = read_line.split
p = read_line.split.map(&.to_i)

h = m.times.map{ |i| {d[i], p[i + 1]} }.to_h

puts c.map{ |c_| h[c_]? || p[0] }.sum

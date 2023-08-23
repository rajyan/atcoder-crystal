n, m = read_line.split.map(&.to_i)
c = read_line.split
d = read_line.split
p = read_line.split.map(&.to_i)
p0 = p.shift
h = Hash.zip(d, p)

puts c.map { |c| h.fetch(c, p0) }.sum

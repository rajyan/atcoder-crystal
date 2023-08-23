n, p, q = read_line.split.map(&.to_i)
d = read_line.split.map(&.to_i)

puts [p, q + d.min].min
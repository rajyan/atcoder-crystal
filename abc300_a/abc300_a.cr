n, a, b = read_line.split.map(&.to_i)
c = read_line.split.map(&.to_i)
puts c.index(a + b).not_nil! + 1

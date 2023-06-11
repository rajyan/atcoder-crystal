coor = [0, 3, 4, 8, 9, 14, 23]
p, q = read_line.split.map { |s| s[0] - 'A' }
puts (coor[p] - coor[q]).abs

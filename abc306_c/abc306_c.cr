n = read_line.to_i
a = read_line.split.map(&.to_i)

count = Array.new(n, 0)
ans = a.map do |a_|
  count[a_ - 1] += 1
  a_ if count[a_ - 1] == 2
end.compact.join(' ')
puts ans
n = read_line.to_i
a = read_line.split.map(&.to_i)
a << a[-1] + 1

ans = n.times.map do |i|
  if a[i] < a[i + 1]
    a[i]...a[i + 1]
  else
    (-a[i]...-a[i + 1]).map(&.-)
  end
end
puts ans.map(&.to_a).flatten.join(' ')

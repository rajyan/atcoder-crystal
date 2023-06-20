n = read_line.to_i
a = read_line.split.map(&.to_i)

n.pred.times do |i|
  if a[i] < a[i + 1]
    puts (a[i]...a[i + 1]).join(' ')
  else
    puts (-a[i]...-a[i + 1]).map(&.-).join(' ')
  end
end
puts a[-1]

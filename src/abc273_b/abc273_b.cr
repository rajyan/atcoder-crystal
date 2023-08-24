x, k = read_line.split.map(&.to_i64)
k.times do |i|
  x = x.round(-(i + 1), mode: :TIES_AWAY)
end

puts x

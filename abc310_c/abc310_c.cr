n = read_line.to_i

set = Set(String).new
ans = 0
n.times do
  s = read_line
  next if set.includes?(s)
  ans += 1
  set << s
  set << s.reverse
end

puts ans

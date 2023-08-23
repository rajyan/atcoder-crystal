n = read_line.to_i

l = 0
r = n - 1
until l + 1 == r
  m = (l + r) // 2
  puts "? #{m + 1}"
  STDOUT.flush
  sm = read_line.to_i
  if sm == 1
    r = m
  else
    l = m
  end
end

puts "! #{l + 1}"
STDOUT.flush
exit

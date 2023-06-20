s = read_line
n = read_line.to_u64
ans = s.gsub('?', '0').to_u64(2)

if ans > n
  puts -1
  exit
end

pow = 2_u64 ** s.size
s.size.times do |i|
  pow //= 2
  next if s[i] != '?'
  ans += pow if pow + ans <= n
end

puts ans

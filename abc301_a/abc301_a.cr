n = read_line.to_i
s = read_line

t = 0; a = 0
n.times do |i|
  if s[i] == 'T'
    t += 1
  else
    a += 1
  end
end

if t == a
  puts s[-1] == 'T' ? 'A' : 'T'
elsif t > a
  puts 'T'
else
  puts 'A'
end

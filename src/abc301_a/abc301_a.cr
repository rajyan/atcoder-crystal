n = read_line.to_i
s = read_line

t = s.count('T')
a = n - t
if t == a
  puts s[-1] == 'T' ? 'A' : 'T'
elsif t > a
  puts 'T'
else
  puts 'A'
end

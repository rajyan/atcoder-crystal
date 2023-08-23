s = read_line.split.map(&.to_i)

if s.sort == s && s.all? { |s_| 100 <= s_ <= 675 } && s.all? { |s_| s_ % 25 == 0 }
  puts "Yes"
else
  puts "No"
end

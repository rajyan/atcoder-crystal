n = read_line.to_i
s = Array.new(n) { read_line }

ans = 0
n.times do |i|
  n.times do |j|
    next if i == j
    ss = s[i] + s[j]
    if ss == ss.reverse
      puts "Yes"
      exit
    end
  end
end

puts "No"

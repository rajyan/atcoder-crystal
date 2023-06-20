macro dump(*vs)
  {% for v in vs %}
    STDERR.puts {{v.stringify}} + "=#{{{v}}}"
  {% end %}
end

s = read_line
t = read_line
A = "atcoder@"

cnt = Array.new(128, 0)
t.each_char { |c| cnt[c - '@'] += 1 }
dump cnt

s.each_char do |c|
  next if c == '@'
  next cnt[c - '@'] -= 1 if cnt[c - '@'] != 0
  next cnt[0] -= 1 if cnt[0] != 0 && A.includes?(c)
  puts "No"
  exit
end

cnt.each_with_index do |c, i|
  next if c == 0
  next if A.includes?('@' + i)
  puts "No"
  exit
end

puts "Yes"

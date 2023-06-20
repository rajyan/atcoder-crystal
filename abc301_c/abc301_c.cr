macro dump(*vs)
  {% for v in vs %}
    STDERR.puts {{v.stringify}} + "=#{{{v}}}"
  {% end %}
end

s = read_line
t = read_line

cnt = Array.new(27, 0)
t.each_char do |c|
  if c == '@'
    cnt[-1] += 1
  else
    cnt[c - 'a'] += 1
  end
end
dump cnt

s.each_char do |c|
  next if c == '@'
  if cnt[c - 'a'] != 0
    cnt[c - 'a'] -= 1
  elsif cnt[-1] != 0 && "atcoder".includes?(c)
    cnt[-1] -= 1
  else
    puts "No"
    exit
  end
end

cnt.each_with_index do |c, i|
  next if c == 0
  next if "atcoder{".includes?('a' + i)
  puts "No"
  exit
end

puts "Yes"

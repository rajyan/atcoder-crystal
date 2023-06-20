macro dump(*vs)
  {% for v in vs %}
    STDERR.puts {{v.stringify}} + "=#{{{v}}}"
  {% end %}
end

s = read_line.rjust(64, '0')
n = read_line.to_u64.to_s(2).rjust(64, '0')

ans = Array.new(64, '?')
ok_i = nil
latest_q_1 = nil
64.times do |i|
  next if s[i] == n[i]
  next if s[i] == '?' && n[i] == '0'
  if s[i] == '?'
    latest_q_1 = i
    next
  end
  if s[i] == '0' && n[i] == '1'
    ok_i = i
    break
  end
  if latest_q_1.nil?
    puts -1
    exit
  end
  ok_i = latest_q_1
  ans[latest_q_1] = '0'
  break
end

l = ok_i || 64
(0...l).each do |i|
  ans[i] = n[i]
end
dump ans
(l...64).each do |i|
  next if ans[i] != '?'
  if s[i] == '?'
    ans[i] = '1'
  else
    ans[i] = s[i]
  end
end

puts ans.join.to_u64(2)

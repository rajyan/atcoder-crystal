macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

n = read_line.to_i
s = read_line

cnt = 0
ans = [] of Char
s.each_char do |c|
  case c
  when '('
    cnt += 1
    ans << c
  when ')'
    if cnt > 0
      until ans.pop == '('; end
      cnt -= 1
    else
      ans << c
    end
  else
    ans << c
  end
  dump ans, cnt
end

puts ans.join

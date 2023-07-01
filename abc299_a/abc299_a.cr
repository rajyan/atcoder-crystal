macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

read_line
s = read_line.split('|')

dump s

puts s[1].includes?('*') ? "in" : "out"
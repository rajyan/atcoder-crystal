read_line
s = read_line

if s.chars.all?(&.==(s[0]))
  puts -1
  exit
end

sz = s.split('-')
ans = sz.max_of{ |c| c.size }

macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

assert(ans >= 1)
puts ans


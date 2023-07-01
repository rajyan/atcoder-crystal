require "big"
n = read_line.to_i

ans = Array.new(n) do |i|
  a, b = read_line.split.map(&.to_i)
  {BigRational.new(-a, a + b), i}
end.sort

puts ans.map(&.[1]).map(&.+(1)).join(' ')
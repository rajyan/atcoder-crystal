macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

n = read_line.to_i
a = read_line.split.map(&.to_i64)
sum = [0_i64]
(1...n).each do |i|
  prev = sum.last
  if i.even?
    sum << prev + a[i] - a[i - 1]
  else
    sum << prev
  end
end

dump a, sum

delta = -> (i: Int64, t: Int64) {
  if i.odd?
    0_i64
  else
    t - a[i]
  end
}

q = read_line.to_i
q.times do
  l, r = read_line.split.map(&.to_i64)
  dump l, r
  li = a.bsearch_index { |a_| l < a_ } || n - 1
  ri = a.bsearch_index { |a_| r < a_ } || n - 1

  dump li, ri
  puts sum[ri] - sum[li] - (delta.call(li.to_i64, l) - delta.call(ri.to_i64, r))
end

require "atcoder/priority_queue"

macro dump(*vs)
  # o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  # STDERR.puts o
end

n, m, k = read_line.split.map(&.to_i64)
edges = Array.new(n) { [] of Int32 }
m.times do
  a, b = read_line.split.map(&.to_i)
  edges[a - 1] << b - 1
  edges[b - 1] << a - 1
end

q = AtCoder::PriorityQueue(Array(Int64)).new { |a, b| a[1] <= b[1] }
k.times do
  p, h = read_line.split.map(&.to_i64)
  q << [p - 1, h]
end
dump q.first

safe = Array.new(n) { false }
loop do
  p, h = (q.pop || break)
  next if safe[p]
  safe[p] = true

  edges[p].each do |u|
    q << [u.to_i64, h - 1] if h > 0
  end
end
dump safe

ans = safe.map_with_index(1) { |v, i| i if v }.compact
puts ans.size
puts ans.join(' ')

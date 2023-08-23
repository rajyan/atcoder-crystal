macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

INF = 10_i64 ** 15

n, m = read_line.split.map(&.to_i)
edges = Array.new(m + 5 * (10 ** 5)) { [] of Tuple(Int32, Int32) }
offset = m

n.times do
  a = read_line.to_i
  s = read_line.split.map(&.to_i)
  a.times do |i|
    u = s[i] - 1
    v = i + offset
    edges[u] << {v, 1}
    edges[v] << {u, 1}
    break if i == a - 1
    w = i + offset + 1
    edges[v] << {w, 0}
    edges[w] << {v, 0}
  end
  offset += a
end

dump edges[1..10]

deq = Deque(Int32).new
deq << 0
visited = Array.new(m + 5 * (10 ** 5)) { false }
cost = Array.new(m + 5 * (10 ** 5)) { INF }
cost[0] = 0
until deq.empty?
  now = deq.shift
  next if visited[now]
  visited[now] = true
  edges[now].each do |(v, c)|
    cost[v] = [cost[v], cost[now] + c].min
    if c == 1
      deq.push(v)
    else
      deq.unshift(v)
    end
  end
end

dump cost[0..m]
puts cost[m - 1] == INF ? -1 :  cost[m - 1] // 2 - 1

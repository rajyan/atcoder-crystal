macro chmin(a, b)
 ({{a}} > {{b}} && ({{a}} = {{b}}))
end

class Queue(T) < Deque(T)
  def pop
    raise Exception.new
  end

  def pop?
    raise Exception.new
  end
end

n, m = read_line.split.map(&.to_i)
edges = Array.new(n) { [] of Int32 }
m.times do
  u, v = read_line.split.map(&.to_i)
  u -= 1; v -= 1
  edges[u] << v
  edges[v] << u
end

INF = 10 ** 7
dist = Array.new(n) do |u|
  cost = Array.new(n, INF)
  cost[u] = 0
  deq = Queue{u}
  until deq.empty?
    now = deq.shift
    edges[now].each do |nex|
      next unless chmin(cost[nex], cost[now] + 1)
      deq << nex
    end
  end
  cost
end

k = read_line.to_i
pd = Array.new(k) { p, d = read_line.split.map(&.to_i);  {p - 1, d} }
is_black = Array.new(n, true)
pd.each do |(p, d)|
  dist[p].each_with_index do |dist_pu, u|
    if dist_pu < d
      is_black[u] = false
    end
  end
end

unless is_black.any?
  puts "No"
  exit
end

pd.each do |(p, d)|
  unless dist[p].each.with_index.any? { |dist_pu, u| dist_pu == d && is_black[u] }
    puts "No"
    exit
  end
end

puts "Yes"
puts is_black.map { |b| b ? '1' : '0' }.join

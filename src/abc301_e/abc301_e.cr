macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

macro chmax(a, b)
 ({{a}} < {{b}} && ({{a}} = {{b}}))
end

macro chmin(a, b)
 ({{a}} > {{b}} && ({{a}} = {{b}}))
end

class Array
  def [](c : Tuple(Int32, Int32))
    self[c[0]][c[1]]
  end

  def []=(c : Tuple(Int32, Int32), v)
    self[c[0]][c[1]] = v
  end
end

INF = 10**8
h, w, t = read_line.split.map(&.to_i)
a = Array.new(h) { read_line.chars }

nodes = [] of {Int32, Int32}
start = goal = nil
h.times do |i|
  w.times do |j|
    case a[i][j]
    when 'S'
      start = {i, j}
    when 'G'
      goal = {i, j}
    when 'o'
      nodes << {i, j}
    end
  end
end
assert(!start.nil?)
assert(!goal.nil?)

bfs = ->(p : Tuple(Int32, Int32)) {
  cost = Array.new(h) { Array.new(w, INF) }
  cost[p] = 0
  deq = Deque{p}
  until deq.empty?
    from = deq.shift
    [{1, 0}, {0, 1}, {-1, 0}, {0, -1}].each do |delta|
      to = {from[0] + delta[0], from[1] + delta[1]}
      next unless 0 <= to[0] < h && 0 <= to[1] < w
      next if a[to] == '#' || cost[to] != INF
      cost[to] = cost[from] + 1
      next if cost[to] > t
      deq << to
    end
  end
  cost
}

n = nodes.size
start_bfs = bfs.call(start)
goal_bfs = bfs.call(goal)
dist = Array.new(n) { |i| i_bfs = bfs.call(nodes[i]); Array.new(n) { |j| i_bfs[nodes[j]] } }
if start_bfs[goal] > t
  puts -1
  exit
end

# dp[今いるノード][通ったノードの状態] = 最小コスト
dp = Array.new(n) { |i| Array.new(2 ** n) { |j| j == (2 ** i) ? start_bfs[nodes[i]] : INF } }
(1...2**n).each do |bit|
  n.times do |i|
    next if dp[i][bit] == INF
    n.times do |j|
      cost = dp[i][bit] + dist[i][j]
      chmin(dp[j][bit | (2 ** j)], cost)
    end
  end
end

ans = 0
n.times do |i|
  goal_dist = goal_bfs[nodes[i]]
  next if goal_dist > t
  dp[i].each_with_index do |cost, bit|
    next if cost + goal_dist > t
    chmax(ans, bit.to_s(2).count('1'))
  end
end
puts ans

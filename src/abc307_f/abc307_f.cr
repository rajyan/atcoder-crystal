require "atcoder/seg_tree"
require "atcoder/priority_queue"

macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

n, m = read_line.split.map(&.to_i)
edges = Array.new(n) { [] of {Int32, Int32} }
m.times do
  u, v, w = read_line.split.map(&.to_i)
  u -= 1; v -= 1
  edges[u] << {v, w}
  edges[v] << {u, w}
end
dump edges

k = read_line.to_i
a = read_line.split.map(&.to_i)
d = read_line.to_i
x = read_line.split.map(&.to_i).unshift(-1)
xs = x.map_with_index{ |xi, i| {xi, i} }.sort
tree = AtCoder::SegTree.new(xs.map(&.[1])) { |a, b| [a, b].min }
dump xs, tree.values

id = -> (y: {Int32, Int32}) {
  dump y
  xs.bsearch_index{ |xsi| xsi > y }
}

# {day, cost, next}
pq = AtCoder::PriorityQueue({Int32, Int32, Int32}).new { |a, b| a >= b }
a.each { |e| pq << {0, 0, e - 1} }

cost = Array.new(n) { {Int32::MAX, 0} }
a.each { |e| cost[e - 1] = {0, 0} }

tday = 0
until pq.empty?
  day, c, u = pq.pop || break
  next if {day, c} != cost[u] # 他で最小が更新されている

  edges[u].each do |v, w|
    nex = if c.to_i64 + w <= x[day]
            # その日に遷移するパターン
            # コストはその日の移動でかかっている分を引き継いでいる
            STDERR.puts "today"
            {day, c + w}
          else
            # day以前には戻れない
            (tday..day).each do |d|
              index = id.call({x[d], d})
              assert(index)
              tree.set(index, Int32::MAX)
              dump tree.values
            end
            tday = day + 1
            # 次の日以降に遷移するパターン
            # コストは0にリセットされる
            # w以下のコストでいけるうちのdayが小さいものを探す
            index = id.call({w, day})
            next unless index
            l = tree[0..index]
            next if l == Int32::MAX
            STDERR.puts "nex"
            {l + 1, w}
          end
    dump day, u, v, w, nex
    if nex < cost[v]
      cost[v] = nex.dup
      pq << {*nex, v}
    end
  end
end

dump cost

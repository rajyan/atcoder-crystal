macro chmin(a, b)
 ({{a}} > {{b}} && ({{a}} = {{b}}))
end

macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

n1, n2, m = read_line.split.map(&.to_i)
e1 = Array.new(n1) { [] of Int32 }
e2 = Array.new(n2) { [] of Int32 }

m.times do
  a, b = read_line.split.map(&.to_i.pred)
  if 0 <= a < n1
    e1[a] << b
    e1[b] << a
  else
    a, b = n1 + n2 - 1 - a, n1 + n2 - 1 - b
    e2[a] << b
    e2[b] << a
  end
end

class Queue(T) < Deque(T)
  def pop
    raise Exception.new("Use shift!")
  end

  def pop?
    raise Exception.new("Use shift!")
  end
end

calc = ->(edges : Array(Array(Int32))) {
  cost = Array(Int32).new(edges.size, 10 ** 7)
  cost[0] = 0
  queue = Queue(Int32).new
  queue << 0
  until queue.empty?
    now = queue.shift
    edges[now].each do |nex|
      next unless chmin(cost[nex], cost[now] + 1)
      queue << nex
    end
  end
  cost
}

puts calc.call(e1).max + calc.call(e2).max + 1

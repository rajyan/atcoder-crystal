macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

n, q = read_line.split.map(&.to_i)
queries = Array.new(q) { read_line.split.map(&.to_i) << 0 }

count = n
edges = Array.new(n) { Set(Int32).new }
queries.each do |(t, u, v)|
  u -= 1; v -= 1
  if t == 1
    n -= 1 if edges[u].empty?
    n -= 1 if edges[v].empty?
    edges[u].add(v)
    edges[v].add(u)
  else
    edges[u].each do |v|
      edges[v].delete(u)
      n += 1 if edges[v].empty?
    end
    n += 1 unless edges[u].empty?
    edges[u].clear
  end
  puts n
end

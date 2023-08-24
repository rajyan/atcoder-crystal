s, t, m = read_line.split.map(&.to_i)

edges = Array.new(s) { [] of Int32 }
m.times do
  u, v = read_line.split.map(&.to_i.pred)
  edges[u] << v - s
end

memo = Array.new(t) { Array(Int32).new(t, -1) }
s.times do |i|
  edges[i].each_combination(2) do |(a, b)|
    a, b = b, a if a > b
    next memo[a][b] = i if memo[a][b] == -1
    puts "#{i + 1} #{a + s + 1} #{memo[a][b] + 1} #{b + s + 1}"
    exit
  end
end

puts -1

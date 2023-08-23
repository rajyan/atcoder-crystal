macro dump(*vs)
  o="{% for v in vs %}{{v.id}}=#{{{v.id}}}\n{% end %}"
  STDERR.puts o
end

_ = read_line
visited = Array.new(101) { |i| i == 1 }
stack = [] of Int32
prev = 1

loop do
  line = read_line
  exit if line == "OK"

  output = nil
  edges = line.split.map(&.to_i)
  edges[1...].each do |now|
    next if visited[now]
    visited[now] = true
    output = now
    break
  end

  if output.nil?
    output = stack.pop
  else
    stack << prev
  end
  puts output
  STDOUT.flush
  prev = output
end

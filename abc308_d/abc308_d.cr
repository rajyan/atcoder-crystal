macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

class Queue(T) < Deque(T)
  def pop
    raise Exception.new
  end

  def pop?
    raise Exception.new
  end
end

SNUKE = "snuke"
h, w = read_line.split.map(&.to_i)
s = Array.new(h) { read_line.chars }

used = Array.new(h) { Array.new(w, false) }
q = Queue{ {0, 0, 0} }
until q.empty?
  x, y, i = q.shift
  dump({x, y, i})
  next if SNUKE[i] != s[x][y]
  next if used[x][y]

  if x == h - 1 && y == w - 1
    puts "Yes"
    exit
  end

  used[x][y] = true
  [{1, 0}, {0, 1}, {-1, 0}, {0, -1}].each do |dx, dy|
    nx, ny = x + dx, y + dy
    next unless 0 <= nx < h && 0 <= ny < w
    q << {nx, ny, (i + 1) % SNUKE.size}
  end
end

puts "No"

macro dump(*vs)
  {% for v in vs %}
    STDERR.puts {{v.stringify}} + "=#{{{v}}}"
  {% end %}
end

h, w = read_line.split.map(&.to_i)
a = Array.new(h) { read_line.chars }
b = Array.new(h) { read_line.chars }

h.times do |i|
  w.times do |j|
    ok = true
    h.times do |di|
      w.times do |dj|
        ok = false if a[(i + di) % h][(j + dj) % w] != b[di][dj]
      end
      break unless ok
    end
    if ok
      puts "Yes"
      exit
    end
  end
end

puts "No"

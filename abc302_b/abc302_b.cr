h, w = read_line.split.map(&.to_i)
s = Array.new(h) { read_line }
S = "snuke"

h.times do |i|
  w.times do |j|
    [-1, 0, 1].each_repeated_permutation(2) do |(di, dj)|
      index = 5.times.map { |k| [i + di * k, j + dj * k] }.to_a
      next if index.any? { |(i, j)| i < 0 || j < 0 || i >= h || j >= w }
      next if index.map { |(i, j)| s[i][j] }.join != S
      index.each { |(i, j)| puts "#{i + 1} #{j + 1}" }
      exit
    end
  end
end

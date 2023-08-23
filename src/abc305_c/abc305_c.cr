h, w = read_line.split.map(&.to_i)
grid = h.times.map { read_line.chars }.to_a

h.times do |i|
  w.times do |j|
    next if grid[i][j] == '#'
    if grid.dig?(i - 1, j) == '#' && grid.dig?(i - 1, j - 1) == '#' && grid.dig?(i, j - 1) == '#' ||
       grid.dig?(i - 1, j) == '#' && grid.dig?(i - 1, j + 1) == '#' && grid.dig?(i, j + 1) == '#' ||
       grid.dig?(i + 1, j) == '#' && grid.dig?(i + 1, j - 1) == '#' && grid.dig?(i, j - 1) == '#' ||
       grid.dig?(i + 1, j) == '#' && grid.dig?(i + 1, j + 1) == '#' && grid.dig?(i, j + 1) == '#'
      puts "#{i + 1} #{j + 1}"
      exit
    end
  end
end

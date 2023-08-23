macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

h, w = read_line.split.map(&.to_i)
c = Array.new(h) { read_line.chars }

delete_cross = ->(i : Int32, j : Int32) {
  deq = Deque{ {i, j} }
  size = 0
  until deq.empty?
    x, y = deq.shift
    next if c[x][y] == '.'
    size += 1
    c[x][y] = '.'
    [{1, 1}, {1, -1}, {-1, -1}, {-1, 1}].each do |(dx, dy)|
      nx, ny = x + dx, y + dy
      next unless 0 <= nx < h && 0 <= ny < w
      next if c[nx][ny] == '.'
      deq << {nx, ny}
    end
  end
  assert((size - 1) % 4 == 0)
  (size - 1) // 4
}

ans = Array.new([h, w].min, 0)
h.times do |i|
  w.times do |j|
    if c[i][j] == '#'
      size = delete_cross.call(i, j)
      ans[size - 1] += 1
    end
  end
end

puts ans.join(' ')

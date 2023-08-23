ha, wa = read_line.split.map(&.to_i)
a = Array.new(ha) { read_line.chars }

hb, wb = read_line.split.map(&.to_i)
b = Array.new(hb) { read_line.chars }

hx, wx = read_line.split.map(&.to_i)
x = Array.new(hx) { read_line.chars }

L = 50
x_black = x.map(&.count('#')).sum
(0...(L - hb)).each do |bi|
  (0...(L - wb)).each do |bj|
    now = Array.new(L) { Array(Char).new(L) { '.' } }
    L.times do |i|
      L.times do |j|
        now_a = 0 <= i - 20 < ha && 0 <= j - 20 < wa ? a[i - 20][j - 20] : '.'
        now_b = 0 <= i - bi < hb && 0 <= j - bj < wb ? b[i - bi][j - bj] : '.'
        # memo ['#', '.'].min == '#'
        now[i][j] = [now_a, now_b].min
      end
    end
    next if now.map(&.count('#')).sum != x_black

    (0...(L - hx)).each do |xi|
      (0...(L - wx)).each do |xj|
        if x.each.with_index.all? { |x_i, i| x_i == now[i - xi][-xj...(-xj + wx)] }
          puts "Yes"
          exit
        end
      end
    end
  end
end

puts "No"

macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

n = read_line.to_i
a = read_line.split.map(&.to_i)
b = a.sort

# indices: [ある位置iの1~4][ソート後のその位置の1~4] << i
indices = Array.new(4) { Array.new(4) { Deque(Int32).new } }
n.times do |i|
  next if a[i] == b[i]
  indices[a[i] - 1][b[i] - 1] << i
end

ans = 0
until indices.flatten.all?(&.empty?)
  # swapで両方ソート状態になるものは得
  4.times.to_a.each_combination(2) do |(i, j)|
    until indices[i][j].empty? || indices[j][i].empty?
      a.swap(indices[i][j].pop, indices[j][i].pop)
      ans += 1
    end
  end

  # 上記のパターンがなければ適当に入れ替えて1つ消す
  4.times.to_a.each_permutation(3) do |(i, j, k)|
    next if indices[i][j].empty? || indices[j][k].empty?
    index = indices[j][k].pop
    a.swap(indices[i][j].pop, index)
    indices[i][k] << index
    ans += 1
    break
  end
end

assert(a == b)
puts ans

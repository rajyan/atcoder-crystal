require "atcoder/red_black_tree"

n, k, q = read_line.split.map(&.to_i)
a = Array.new(n, 0)
min_tree = AtCoder::RedBlackTree.new
k.times { min_tree << 0 }
max_tree = AtCoder::RedBlackTree.new
(n - k).times { max_tree << 0 }

sum = 0_i64

q.times do
  x, y = read_line.split.map(&.to_i)
  x -= 1

  min = min_tree.min
  max = max_tree.max
  prev = a[x]
  a[x] = y

  if min <= prev
    min_tree.delete(prev)
    if max < y
      min_tree << y
      sum += y - prev
    else
      max_tree.delete(max)
      min_tree << max
      max_tree << y
      sum += max - prev
    end
  else
    max_tree.delete(prev)
    if y < min
      max_tree << y
    else
      min_tree.delete(min)
      max_tree << min
      min_tree << y
      sum += y - min
    end
  end

  puts sum
end

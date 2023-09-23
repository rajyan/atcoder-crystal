require "atcoder/fenwick_tree"

n, m = read_line.split.map(&.to_i)
a = Array.new(n) { read_line.split.map(&.to_i).sort }
index = a.flatten.sort.map_with_index { |k, v| [k, v] }.to_h
a.map!{ |a_| a_.map!{ |aa| index[aa] }} # compress

ft = AtCoder::FenwickTree(UInt64).new((m * n).to_i64)
sum = n.to_u64 * (n - 1) // 2 * (m + m * (m - 1) // 2)
a.reverse.each do |a_|
  a_.each do |i|
    sum += ft[0...i]
  end
  a_.each do |i|
    ft.add(i, 1)
  end
end

puts sum

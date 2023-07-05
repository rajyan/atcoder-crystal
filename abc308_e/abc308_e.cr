n = read_line.to_i
a = read_line.split.map(&.to_i)
s = read_line

# i文字目まで見たとき x {0, 1, 2}のbitフラグ x MEXの何文字目まで完成しているか
dp = Array.new(1 << 3) { Array.new(4, 0_i64) }
dp[0][0] = 1
n.times do |i|
  dp_next = dp.dup
  (1 << 3).times do |bit|
    3.times do |j|
      dp_next[bit | (1 << a[i])][j + 1] += dp[bit][j] if "MEX"[j] == s[i]
    end
  end
  dp = dp_next
end

mex = -> (bit: Int32) {
  bit = bit.to_s(2).rjust(3, '0').reverse
  bit.index('0') || 3
}

puts (1 << 3).times.map{ |bit| dp[bit][3] * mex.call(bit) }.sum

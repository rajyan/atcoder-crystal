macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

n = read_line.to_i
a = read_line.split.map(&.to_i)
s = read_line

MEX = "MEX"
# i文字目まで見たとき x {0, 1, 2}のbitフラグ x MEXの何文字目まで完成しているか
dp = Array.new(n + 1) { Array.new(1 << 3) { Array.new(4, 0_i64) } }
dp[0][0][0] = 1
n.times do |i|
  (1 << 3).times do |bit|
    4.times do |j|
      dp[i + 1][bit][j] += dp[i][bit][j]
      next if j == 3
      if MEX[j] == s[i]
        dp[i + 1][bit | (1 << a[i])][j + 1] += dp[i][bit][j]
      end
    end
  end
end

dump dp[1]

mex = -> (bit: Int32) {
  bit = bit.to_s(2).rjust(3, '0').reverse
  dump bit
  res = 3
  bit.chars.each_with_index do |b, i|
    break res = i if b == '0'
  end
  dump res
  res
}

ans = 0_i64
(1 << 3).times do |bit|
  dump({bit, dp[n][bit][1]})
  dump({bit, dp[n][bit][2]})
  dump({bit, dp[n][bit][3]})
  ans += dp[n][bit][3] * mex.call(bit)
end
puts ans
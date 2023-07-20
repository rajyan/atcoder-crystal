n = read_line.to_i
s = read_line

# 累積NANDが{0, 1}となる通り
dp = {0_i64, 0_i64}
puts Array.new(n) { |i| dp = s[i] == '1' ? {dp[1], dp[0] + 1_i64} : {1_i64, dp[0] + dp[1]}; dp[1] }.sum

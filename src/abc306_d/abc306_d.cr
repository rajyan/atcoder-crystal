n = read_line.to_i
dp = Array.new(n + 1) { Array(Int64).new(2) { -(10_i64**18) } }

dp[0][0] = 0
n.times do |i|
  x, y = read_line.split.map(&.to_i64)
  if x == 0
    dp[i + 1][0] = [dp[i][0] + y, dp[i][1] + y, dp[i][0]].max
    dp[i + 1][1] = dp[i][1]
  else
    dp[i + 1][0] = dp[i][0]
    dp[i + 1][1] = [dp[i][0] + y, dp[i][1]].max
  end
end

puts dp[n].max

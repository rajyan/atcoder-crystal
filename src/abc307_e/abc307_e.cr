require "atcoder/mod_int"

alias Mint = AtCoder::ModInt998244353

n, m = read_line.split.map(&.to_i)
# 0: 先頭と違う 1: 先頭と同じ
dp = {0, Mint.new(m)}

(n - 1).times do
  dp = {dp[0] * (m - 2) + dp[1] * (m - 1), dp[0]}
end

puts dp[0]

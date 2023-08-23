require "atcoder/mod_int"
alias Mint = AtCoder::ModInt998244353

n = read_line.to_i
a = read_line.split.map(&.to_i)

# 1 << i : ここまででiを作ることができる通り
dp = Array.new(n + 1) { Array.new(1 << 11) { Mint.new(0) } }
dp[0][1 << 0] = Mint.new(1)

n.times do |i|
  (0...(1 << 11)).each do |bit|
    (1..{a[i], 10}.min).each do |dice|
      dp[i + 1][(bit | (bit << dice)) & ((1 << 11) - 1)] += dp[i][bit]
    end
    dp[i + 1][bit] += dp[i][bit] * {a[i] - 10, 0}.max
  end
end

puts dp[n][(1 << 10)...].sum / a.map{ |e| Mint.new(e) }.product(1)

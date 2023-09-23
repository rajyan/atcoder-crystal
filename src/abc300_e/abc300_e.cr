require "atcoder/mod_int"

alias Mint = AtCoder::ModInt998244353

n = read_line.to_i64
f = AtCoder::Prime.prime_division(n)

if f.any? { |(k, _)| k > 5 }
  puts 0
  exit
end

f = f.to_h
f[2] ||= 0
f[3] ||= 0

ans = Mint.new(0)
# 4,6の数を決め打つ
(0..(f[2] // 2)).each do |i|
  (0..[f[2], f[3]].max).each do |j|
    now = f.dup
    now[2] -= i * 2 + j
    now[3] -= j
    now[4] = i.to_i64
    now[6] = j.to_i64
    next if now[2] < 0 || now[3] < 0
    cnt = now.select{ |_, cnt| cnt > 0 }.values
    ans += Mint.factorial(cnt.sum) / cnt.map{ |c| Mint.factorial(c) }.product(1) / Mint.new(5) ** cnt.sum
  end
end
puts ans

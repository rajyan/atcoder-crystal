require "big"
require "atcoder/prime"

n = read_line.to_big_i
PN = 30_000
primes = AtCoder::Prime.first(PN)

ans = 0
PN.times do |i|
  a = primes[i]
  next if a.to_big_i**5 > n
  ((i + 1)...PN).each do |j|
    b = primes[j]
    next if a.to_big_i**2 * b**3 > n
    k = primes.bsearch_index { |c| a.to_big_i ** 2 * b * c ** 2 > n } || PN
    ans += k - j - 1 if k - j - 1 > 0
  end
end
puts ans

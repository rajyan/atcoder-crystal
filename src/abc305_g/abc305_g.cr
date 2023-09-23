require "atcoder/mod_int"

alias Mint = AtCoder::ModInt998244353

n, m = read_line.split.map(&.to_i64)
s = m.times.map { read_line.chars.map { |c| c == 'a' ? 1 : 0 }.join }.to_a
banned = ->(t : String) { s.any? { |s_| t.includes?(s_) } }

L = 2 ** 5
id = L.times.map { |i| [i.to_s(2).rjust(5, '0'), i] }.to_h

A = Array.new(L) { Array.new(L) { Mint.new(0) } }
id.each do |k, v|
  2.times do |i|
    l = "#{k}#{i}"
    next if banned.call(l)
    A[id[l[1...]].to_i][v.to_i] = Mint.new(1)
  end
end

mul = ->(a : typeof(A), b : typeof(A)) {
  L.times.map do |i|
    L.times.map do |j|
      L.times.map do |k|
        a[i][k] * b[k][j]
      end.sum
    end.to_a
  end.to_a
}

AA = [] of typeof(A)
AA << A
64.times do
  aa = AA.last
  AA << mul.call(aa, aa)
end

if (n < 5)
  ans = 0
  (2 ** n).times do |i|
    l = i.to_s(2).rjust(n, '0')
    next if banned.call(l)
    ans += 1
  end
  puts ans
  exit
end

b = id.map { |k, _| Mint.new(banned.call(k.to_s) ? 0 : 1) }
a = Array.new(L) { |i| Array.new(L) { |j| Mint.new(i == j ? 1 : 0) } }
(n - 5).to_s(2).reverse.each_char.with_index do |c, i|
  next if (c == '0')
  a = mul.call(a, AA[i])
end

puts a.map { |a_| L.times.map { |i| a_[i] * b[i] }.sum }.sum

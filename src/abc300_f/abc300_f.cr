n, m, k = read_line.split.map(&.to_i64)
s = read_line

sum = Array.new(2 * n + 1, 0_i64)
(2*n).times do |i|
  sum[i + 1] = sum[i] + (s[i % n] == 'x' ? 1 : 0)
end

range_sum = ->(l : Int64, r : Int64) {
  ll = l % n
  rr = r % n
  rr += n if ll > rr
  sum[rr + 1] - sum[ll] + (r - l) // n * sum[n]
}

puts n.times.map{ |l| ((l..(m*n)).bsearch { |r| range_sum.call(l, r) > k } || m*n) - l }.max

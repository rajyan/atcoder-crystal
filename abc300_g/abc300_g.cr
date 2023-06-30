P = [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97].map(&.to_u64)
n, _p = read_line.split.map(&.to_u64)
P.select!(&.<=(_p))

u = [1_u64]; v = [1_u64]
P.each do |p|
  now = 1_u64
  s = u.size > v.size ? v : u
  len = s.size
  until n // p < now
    now *= p
    (0...len).each do |i|
      next if n // now < s[i]
      s << s[i] * now
    end
  end
end
u.sort!; v.sort!

ans = 0_u64
cnt = v.size
u.each do |e|
  until cnt == 0 || v[cnt - 1] * e <= n
    cnt -= 1
  end
  ans += cnt
end

puts ans

n, m = read_line.split.map(&.to_i)
pcf = Array.new(n) { read_line.split.map(&.to_i) }

pcf.each_permutation(2) do |(pcfi, pcfj)|
  pi, pj = pcfi[0], pcfj[0]
  fi, fj = pcfi[2...], pcfj[2...]

  next if pi < pj
  next if fi.any?{ |f| !fj.includes?(f) }
  next if pi == pj && fi.size == fj.size

  puts "Yes"
  exit
end

puts "No"

n=read_line.to_i

w=(0..100).step(5)

puts w.min_by{|e| (e-n).abs}
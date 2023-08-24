n = read_line.to_i
set = Set(Int32).new
(1..(2 * n + 1)).each do |i|
  next if set.includes?(i)
  puts i
  STDOUT.flush
  set << read_line.to_i
end

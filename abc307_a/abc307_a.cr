n = read_line.to_i
a = read_line.split.map(&.to_i)

a.each_slice(7) do |a_|
  print "#{a_.sum} "
end

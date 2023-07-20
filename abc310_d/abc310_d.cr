n, t, m = read_line.split.map(&.to_i)
ab = Array.new(m) { read_line.split.map(&.to_i) }

ng = ->(team : Array(Int32)) {
  ab.any? { |(a, b)| team.includes?(a - 1) && team.includes?(b - 1) }
}

ans = Set(Array(Array(Int32))).new
(0...n).to_a.each_combination(t) do |selected|
  remainer = (0...n).to_a - selected
  (0...t).to_a.each_repeated_permutation(remainer.size) do |indicies|
    teams = selected.map { |t| Array{t} }
    remainer.each_with_index do |r, i|
      teams[indicies[i]] << r
    end
    next if teams.any? { |team| ng.call(team) }
    ans << teams.map { |t| t.sort }.sort
  end
end

puts ans.size

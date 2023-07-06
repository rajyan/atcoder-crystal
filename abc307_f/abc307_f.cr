macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

macro assert(exp)
  raise {{exp.stringify}} unless {{exp}}
end

n, m = read_line.split.map(&.to_i)
edges = Array.new(n) { [] of {Int32, Int32} }
m.times do
  u, v, w = read_line.split.map(&.to_i)
  u -= 1; v -= 1
  edges[u] << {v, w}
  edges[v] << {u, w}
end
dump edges

k = read_line.to_i
a = read_line.split.map(&.to_i)
d = read_line.to_i
x = read_line.split.map(&.to_i).unshift(-1)
xs = x.map_with_index{ |xi, i| {xi, i} }.sort
tree = AtCoder::SegTree.new(xs.map(&.[1])) { |a, b| [a, b].min }
dump xs, tree.values

id = -> (y: {Int32, Int32}) {
  dump y
  xs.bsearch_index{ |xsi| xsi > y }
}

# {day, cost, next}
pq = AtCoder::PriorityQueue({Int32, Int32, Int32}).new { |a, b| a >= b }
a.each { |e| pq << {0, 0, e - 1} }

cost = Array.new(n) { {Int32::MAX, 0} }
a.each { |e| cost[e - 1] = {0, 0} }

tday = 0
until pq.empty?
  day, c, u = pq.pop || break
  next if {day, c} != cost[u] # 他で最小が更新されている

  edges[u].each do |v, w|
    nex = if c.to_i64 + w <= x[day]
            # その日に遷移するパターン
            # コストはその日の移動でかかっている分を引き継いでいる
            STDERR.puts "today"
            {day, c + w}
          else
            # day以前には戻れない
            (tday..day).each do |d|
              index = id.call({x[d], d})
              assert(index)
              tree.set(index, Int32::MAX)
              dump tree.values
            end
            tday = day + 1
            # 次の日以降に遷移するパターン
            # コストは0にリセットされる
            # w以下のコストでいけるうちのdayが小さいものを探す
            index = id.call({w, day})
            next unless index
            l = tree[0..index]
            next if l == Int32::MAX
            STDERR.puts "nex"
            {l + 1, w}
          end
    dump day, u, v, w, nex
    if nex < cost[v]
      cost[v] = nex.dup
      pq << {*nex, v}
    end
  end
end

dump cost

# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AtCoder
  # Implements [atcoder::segtree](https://atcoder.github.io/ac-library/master/document_en/segtree.html).
  #
  # The identity element will be implicitly defined as nil, so you don't
  # have to manually define it. In the other words, you cannot include
  # nil into an element of the monoid.
  #
  # ```
  # tree = AtCoder::SegTree.new((0...100).to_a) { |a, b| [a, b].min }
  # tree[10...50] # => 10
  # ```
  class SegTree(T)
    getter values : Array(T)

    @height : Int32
    @n_leaves : Int32

    def initialize(values : Array(T))
      initialize(values) { |a, b| a > b ? a : b }
    end

    def initialize(@values : Array(T), &@operator : T, T -> T)
      @height = log2_ceil(@values.size)
      @n_leaves = 1 << @height

      @segments = Array(T | Nil).new(2 * @n_leaves, nil)

      # initialize segments
      values.each_with_index { |x, i| @segments[@n_leaves + i] = x.as(T | Nil) }
      (@n_leaves - 1).downto(1) { |i| refresh(i) }
    end

    @[AlwaysInline]
    private def operate(a : T | Nil, b : T | Nil)
      if a.nil?
        b
      elsif b.nil?
        a
      else
        @operator.call(a, b)
      end
    end

    # Implements atcoder::segtree.set(index, value)
    def []=(index : Int, value : T)
      @values[index] = value

      index += @n_leaves
      @segments[index] = value.as(T | Nil)
      (1..@height).each { |j| refresh(ancestor(index, j)) }
    end

    # Implements atcoder::segtree.get(index)
    def [](index : Int)
      @values[index]
    end

    # Implements atcoder::segtree.prod(l, r)
    def [](range : Range(Int, Int))
      l = range.begin + @n_leaves
      r = (range.exclusive? ? range.end : range.end + 1) + @n_leaves

      sml, smr = nil.as(T | Nil), nil.as(T | Nil)
      while l < r
        if l.odd?
          sml = operate(sml, @segments[l])
          l += 1
        end
        if r.odd?
          r -= 1
          smr = operate(@segments[r], smr)
        end
        l >>= 1
        r >>= 1
      end

      operate(sml, smr).not_nil!
    end

    # compatibility with ac-library

    # Implements atcoder::segtree.set(index, value)
    # alias of `.[]=`
    def set(index : Int, value : T)
      self.[]=(index, value)
    end

    # Implements atcoder::segtree.get(index)
    # alias of `.[]`
    def get(index : Int)
      self.[](index)
    end

    # Implements atcoder::segtree.prod(left, right)
    def prod(left : Int, right : Int)
      self.[](left...right)
    end

    # Implements atcoder::segtree.all_prod(l, r)
    def all_prod
      @segments[1].not_nil!
    end

    # Implements atcoder::lazy_segtree.max_right(left, g).
    def max_right(left, e : T | Nil = nil, & : T -> Bool)
      unless 0 <= left && left <= @values.size
        raise IndexError.new("{left: #{left}} must greater than or equal to 0 and less than or equal to {n: #{@values.size}}")
      end

      unless e.nil?
        return nil unless yield e
      end

      return @values.size if left == @values.size

      left += @n_leaves
      sm = e
      loop do
        while left.even?
          left >>= 1
        end

        res = operate(sm, @segments[left])
        unless res.nil? || yield res
          while left < @n_leaves
            left = 2*left
            res = operate(sm, @segments[left])
            if res.nil? || yield res
              sm = res
              left += 1
            end
          end
          return left - @n_leaves
        end

        sm = operate(sm, @segments[left])
        left += 1

        ffs = left & -left
        break if ffs == left
      end

      @values.size
    end

    # Implements atcoder::lazy_segtree.min_left(right, g).
    def min_left(right, e : T | Nil = nil, & : T -> Bool)
      unless 0 <= right && right <= @values.size
        raise IndexError.new("{right: #{right}} must greater than or equal to 0 and less than or equal to {n: #{@values.size}}")
      end

      unless e.nil?
        return nil unless yield e
      end

      return 0 if right == 0

      right += @n_leaves
      sm = e
      loop do
        right -= 1
        while right > 1 && right.odd?
          right >>= 1
        end

        res = operate(@segments[right], sm)
        unless res.nil? || yield res
          while right < @n_leaves
            right = 2*right + 1
            res = operate(@segments[right], sm)
            if res.nil? || yield res
              sm = res
              right -= 1
            end
          end
          return right + 1 - @n_leaves
        end

        sm = operate(@segments[right], sm)

        ffs = right & -right
        break if ffs == right
      end

      0
    end

    @[AlwaysInline]
    private def refresh(node : Int)
      child1 = 2*node
      child2 = 2*node + 1
      @segments[node] = operate(@segments[child1], @segments[child2])
    end

    @[AlwaysInline]
    private def ancestor(node, n_gens_ago)
      node >> n_gens_ago
    end

    @[AlwaysInline]
    private def log2_ceil(n : Int32) : Int32
      sizeof(Int32)*8 - (n - 1).leading_zeros_count
    end

    @[AlwaysInline]
    private def log2_ceil(n : Int32) : Int32
      sizeof(Int32)*8 - (n - 1).leading_zeros_count
    end
  end
end

# ac-library.cr by hakatashi https://github.com/google/ac-library.cr
#
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

module AtCoder
  # Implements standard priority queue like [std::priority_queue](https://en.cppreference.com/w/cpp/container/priority_queue).
  #
  # ```
  # q = AtCoder::PriorityQueue(Int64).new
  # q << 1_i64
  # q << 3_i64
  # q << 2_i64
  # q.pop # => 3
  # q.pop # => 2
  # q.pop # => 1
  # ```
  class PriorityQueue(T)
    include Enumerable(T)

    getter heap : Array(T)

    # Create a new queue in ascending order of priority.
    def self.max
      self.new { |a, b| a <= b }
    end

    # Create a new queue in ascending order of priority with the elements in *enumerable*.
    def self.max(enumerable : Enumerable(T))
      self.new(enumerable) { |a, b| a <= b }
    end

    # Create a new queue in descending order of priority.
    def self.min
      self.new { |a, b| a >= b }
    end

    # Create a new queue in descending order of priority with the elements in *enumerable*.
    def self.min(enumerable : Enumerable(T))
      self.new(enumerable) { |a, b| a >= b }
    end

    def initialize
      initialize { |a, b| a <= b }
    end

    # Initializes queue with the elements in *enumerable*.
    def self.new(enumerable : Enumerable(T))
      self.new(enumerable) { |a, b| a <= b }
    end

    # Initializes queue with the custom comperator.
    #
    # If the second argument `b` should be popped earlier than
    # the first argument `a`, return `true`. Else, return `false`.
    #
    # ```
    # q = AtCoder::PriorityQueue(Int64).new { |a, b| a >= b }
    # q << 1_i64
    # q << 3_i64
    # q << 2_i64
    # q.pop # => 1
    # q.pop # => 2
    # q.pop # => 3
    # ```
    def initialize(&block : T, T -> Bool)
      @heap = Array(T).new
      @compare_proc = block
    end

    # Initializes queue with the elements in *enumerable* and the custom comperator.
    #
    # If the second argument `b` should be popped earlier than
    # the first argument `a`, return `true`. Else, return `false`.
    #
    # ```
    # q = AtCoder::PriorityQueue.new([1, 3, 2]) { |a, b| a >= b }
    # q.pop # => 1
    # q.pop # => 2
    # q.pop # => 3
    # ```
    def initialize(enumerable : Enumerable(T), &block : T, T -> Bool)
      @heap = enumerable.to_a
      @compare_proc = block

      len = @heap.size
      (len // 2 - 1).downto(0) do |parent|
        v = @heap[parent]
        child = parent * 2 + 1
        while child < len
          if child + 1 < len && @compare_proc.call(@heap[child], @heap[child + 1])
            child += 1
          end
          unless @compare_proc.call(v, @heap[child])
            break
          end
          @heap[parent] = @heap[child]
          parent = child
          child = parent * 2 + 1
        end
        @heap[parent] = v
      end
    end

    # Pushes value into the queue.
    def push(v : T)
      @heap << v
      index = @heap.size - 1
      while index != 0
        parent = (index - 1) // 2
        if @compare_proc.call(@heap[index], @heap[parent])
          break
        end
        @heap[parent], @heap[index] = @heap[index], @heap[parent]
        index = parent
      end
    end

    # Alias of `push`
    def <<(v : T)
      push(v)
    end

    # Pops value from the queue.
    def pop
      if @heap.size == 0
        return nil
      end
      if @heap.size == 1
        return @heap.pop
      end
      ret = @heap.first
      @heap[0] = @heap.pop
      index = 0
      while index * 2 + 1 < @heap.size
        child = if index * 2 + 2 < @heap.size && !@compare_proc.call(@heap[index * 2 + 2], @heap[index * 2 + 1])
                  index * 2 + 2
                else
                  index * 2 + 1
                end
        if @compare_proc.call(@heap[child], @heap[index])
          break
        end
        @heap[child], @heap[index] = @heap[index], @heap[child]
        index = child
      end
      ret
    end

    # Yields each item in the queue in comparator's order.
    def each(&)
      @heap.sort { |a, b| @compare_proc.call(a, b) ? 1 : -1 }.each do |e|
        yield e
      end
    end

    # Returns, but does not remove, the head of the queue.
    def first(&)
      @heap.first { yield }
    end

    # Returns `true` if the queue is empty.
    delegate :empty?, to: @heap

    # Returns size of the queue.
    delegate :size, to: @heap
  end
end

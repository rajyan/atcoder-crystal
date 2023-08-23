n, q = read_line.split.map(&.to_i)
a = read_line.split.map(&.to_i)

rbst = LazyRBST(Monoid).new
a.each_with_index { |a, i| rbst.insert(i, Monoid.new(Mint.new(a))) }

q.times do |i|
  query = read_line.split.map(&.to_i)
  if query.shift == 1
    l, r = query
    puts rbst[l...r].not_nil!.m.not_nil!.acc
  else
    l, r, b, c = query
    rbst.apply(l, r, {Mint.new(b), Mint.new(c)})
  end
end

class LazyRBST(Monoid)
  @@rand = Random.new
  @root : LazyNode(Monoid)? = nil
  getter :root

  def size
    @root.try(&.size) || 0
  end

  def height
    @root.try(&.height) || 0
  end

  def insert(k : Int32, monoid : Monoid, node : Pointer(LazyNode(Monoid)?) = pointerof(@root)) : LazyNode(Monoid)
    return node.value = LazyNode(Monoid).new(monoid) unless node.value

    left, right = split(node.value, k)
    node.value = merge(merge(left, LazyNode(Monoid).new(monoid)), right).not_nil!
  end

  def delete(k : Int32, node : Pointer(LazyNode(Monoid)?) = pointerof(@root)) : LazyNode(Monoid)?
    return unless node.value

    left, mid = split(node.value, k)
    w, right = split(mid, 1)
    node.value = merge(left, right)
  end

  def nth(n : Int32, node : Pointer(LazyNode(Monoid)?) = pointerof(@root)) : LazyNode(Monoid)?
    range(n, n + 1, node)
  end

  # returned node's left, right property is not safe to use
  def range(l : Int32, r : Int32, node : Pointer(LazyNode(Monoid)?) = pointerof(@root))
    return unless node.value

    mid, right = split(node.value, r)
    left, mid = split(mid, l)
    ret = mid.dup
    node.value = merge(merge(left, mid), right).not_nil! # restore
    ret
  end

  def [](n : Int32)
    nth(n)
  end

  def [](r : Range)
    range(r.begin, r.end + (r.excludes_end? ? 0 : 1))
  end

  # {[0...k], [k...n]}
  def split(node : LazyNode(Monoid)?, k : Int32) : {LazyNode(Monoid)?, LazyNode(Monoid)?}
    return {nil, nil} unless node
    raise IndexError.new("k: #{k} is out of tree range") unless 0 <= k <= node.size

    node.propagate
    sz = node.left.try(&.size) || 0
    if k <= sz
      left, right = split(node.left, k)
      node.left = right
      {left, node.fix}
    else
      left, right = split(node.right, k - sz - 1)
      node.right = left
      {node.fix, right}
    end
  end

  def merge(left : LazyNode(Monoid)?, right : LazyNode(Monoid)?) : LazyNode(Monoid)?
    return right || left if right.nil? || left.nil?
    left.propagate
    right.propagate

    if @@rand.rand(left.size + right.size) < left.size
      left.right = merge(left.right, right)
      left.fix
    else
      right.left = merge(left, right.left)
      right.fix
    end
  end

  def apply(l : Int32, r : Int32, x : _ = nil, node : Pointer(LazyNode(Monoid)?) = pointerof(@root))
    mid, right = split(node.value, r)
    left, mid = split(mid, l)
    mid.try &.apply(x)
    node.value = merge(merge(left, mid), right) # restore
  end

  def reverse(l : Int32, r : Int32, node : Pointer(LazyNode(Monoid)?) = pointerof(@root))
    apply(l, r, nil, node)
  end
end

class LazyNode(Monoid)
  @left : LazyNode(Monoid)?
  @right : LazyNode(Monoid)?
  @rev = false
  @size = 1
  @height = 1

  property :left, :right
  getter :size, :height, :rev, :m

  def initialize(@m : Monoid = Monoid.new); end

  def propagate
    if rev
      @rev = false
      @left, @right = right, left
      @left.try &.reverse
      @right.try &.reverse
    end

    return unless x = m.lazy
    @left.try &.apply(x)
    @right.try &.apply(x)
    @m.lazy = nil
  end

  def fix
    @size = (left.try(&.size) || 0) + (right.try(&.size) || 0) + 1
    @height = {left.try(&.height) || 0, right.try(&.height) || 0}.max + 1
    @m.acc = Monoid.op(Monoid.op(m.val, left.try &.m.acc), right.try &.m.acc)
    self
  end

  def apply(x : _)
    return reverse unless x
    @m.lazy = Monoid.compose(x, m.lazy)
    @m.val = Monoid.map(x, m.val, 1)
    @m.acc = Monoid.map(x, m.acc, size)
  end

  def reverse
    @rev = rev ^ true
  end
end

struct Monoid
  alias K = Mint         # fix here
  alias F = {Mint, Mint} # fix here

  @val : K; @acc : K; @lazy : F?
  property :val, :acc, :lazy

  def initialize(@val, @acc = val); end

  # val|acc x val|acc = val|acc -> x・y
  def self.op(x : K, y : K?) : K
    return x unless y
    x + y # fix here
  end

  # lazy x val|acc = val|acc -> f(x)
  def self.map(f : F, x : K?, size : Int32) : K?
    return Mint.new(f[1]) unless x
    f[0] * x + f[1] * size # fix here
  end

  # lazy x lazy = lazy -> f・g
  def self.compose(f : F, g : F?) : F?
    return f unless g
    {f[0] * g[0], f[0] * g[1] + f[1]} # fix here
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
  # Implements [atcoder::static_modint](https://atcoder.github.io/ac-library/master/document_en/modint.html).
  #
  # ```
  # AtCoder.static_modint(ModInt101, 101_i64)
  # alias Mint = AtCoder::ModInt101
  # Mint.new(80_i64) + Mint.new(90_i64) # => 89
  # ```
  macro static_modint(name, modulo)
        module AtCoder
# Implements atcoder::modint{{modulo}}.
      #
      # ```
      # alias Mint = AtCoder::{{name}}
      # Mint.new(30_i64) // Mint.new(7_i64)
      # ```
      struct {{name}}
        MOD = {{modulo}}

        getter value : Int64

        def initialize(@value : Int64)
          @value %= MOD
        end

        def initialize(value)
          @value = value.to_i64 % MOD
        end

        # Change the initial capacity of this array to improve performance
        @@factorials = Array(self).new(100_000_i64)

        def self.factorial(n)
          if @@factorials.empty?
            @@factorials << self.new(1_i64)
          end
          @@factorials.size.upto(n) do |i|
            @@factorials << @@factorials.last * i
          end
          @@factorials[n]
        end

        def self.permutation(n, k)
          raise ArgumentError.new("k cannot be greater than n") unless n >= k
          factorial(n) // factorial(n - k)
        end

        def self.combination(n, k)
          raise ArgumentError.new("k cannot be greater than n") unless n >= k
          permutation(n, k) // @@factorials[k]
        end

        def self.repeated_combination(n, k)
          combination(n + k - 1, k)
        end

        def self.zero
          self.new(0_i64)
        end

        def inv
          g, x = AtCoder::Math.extended_gcd(@value, MOD)
          self.class.new(x)
        end

        def +(value : self)
          self.class.new(@value + value.to_i64)
        end

        def +(value)
          self.class.new(@value + value.to_i64 % MOD)
        end

        def -(value : self)
          self.class.new(@value - value.to_i64)
        end

        def -(value)
          self.class.new(@value - value.to_i64 % MOD)
        end

        def *(value : self)
          self.class.new(@value * value.to_i64)
        end

        def *(value)
          self.class.new(@value * (value.to_i64 % MOD))
        end

        def /(value : self)
          raise DivisionByZeroError.new if value == 0
          self * value.inv
        end

        def /(value)
          raise DivisionByZeroError.new if value == 0
          self * self.class.new(value.to_i64).inv
        end

        def //(value)
          self./(value)
        end

        def **(value)
          self.class.new(AtCoder::Math.pow_mod(@value, value.to_i64, MOD))
        end

        def <<(value)
          self * self.class.new(2_i64) ** value
        end

        def sqrt
          z = self.class.new(1_i64)
          until z ** ((MOD - 1) // 2) == MOD - 1
            z += 1
          end
          q = MOD - 1
          m = 0
          while q % 2 == 0
            q //= 2
            m += 1
          end
          c = z ** q
          t = self ** q
          r = self ** ((q + 1) // 2)
          m.downto(2) do |i|
            tmp = t ** (2 ** (i - 2))
            if tmp != 1
              r *= c
              t *= c ** 2
            end
            c *= c
          end
          if r * r == self
            r.to_i64 * 2 <= MOD ? r : -r
          else
            nil
          end
        end

        def to_i64
          @value
        end

        def ==(value : self)
          @value == value.to_i64
        end

        def ==(value)
          @value == value
        end

        def -
          self.class.new(0_i64) - self
        end

        def +
          self
        end

        def abs
          self
        end

        def pred
          self.class.new(@value - 1)
        end

        def succ
          self.class.new(@value + 1)
        end

        def zero?
          @value == 0
        end

        # ac-library compatibility

        def pow(value)
          self.**(value)
        end

        def val
          self.to_i64
        end

        # ModInt shouldn't be compared

        def <(value)
          raise NotImplementedError.new("<")
        end
        def <=(value)
          raise NotImplementedError.new("<=")
        end
        def >(value)
          raise NotImplementedError.new(">")
        end
        def >=(value)
          raise NotImplementedError.new(">=")
        end

        delegate to_s, to: @value
        delegate inspect, to: @value
      end
    end

    struct Int
      def +(value : AtCoder::{{name}})
        value + self
      end

      def -(value : AtCoder::{{name}})
        -value + self
      end

      def *(value : AtCoder::{{name}})
        value * self
      end

      def //(value : AtCoder::{{name}})
        value.inv * self
      end

      def /(value : AtCoder::{{name}})
        self // value
      end

      def ==(value : AtCoder::{{name}})
        value == self
      end
    end
  end
end

AtCoder.static_modint(ModInt1000000007, 1_000_000_007_i64)
AtCoder.static_modint(ModInt998244353, 998_244_353_i64)
AtCoder.static_modint(ModInt754974721, 754_974_721_i64)
AtCoder.static_modint(ModInt167772161, 167_772_161_i64)
AtCoder.static_modint(ModInt469762049, 469_762_049_i64)

alias Mint = AtCoder::ModInt998244353

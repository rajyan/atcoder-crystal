macro dump(*vs)
  {% for v in vs %}
    STDERR.puts {{v.stringify}} + "=#{{{v}}}"
  {% end %}
end

n = read_line.to_i64
f = AtCoder::Prime.prime_division(n)
dump f

if f.any? { |(k, _)| k > 5 }
  puts 0
  exit
end

f = f.to_h
f[2] ||= 0
f[3] ||= 0

ans = Mint.new(0)
# 4,6の数を決め打つ
(0..(f[2] // 2)).each do |i|
  (0..[f[2], f[3]].max).each do |j|
    now = f.dup
    now[2] -= i * 2 + j
    now[3] -= j
    now[4] = i.to_i64
    now[6] = j.to_i64
    next if now[2] < 0 || now[3] < 0
    cnt = now.select{ |_, cnt| cnt > 0 }.values
    ans += Mint.factorial(cnt.sum) / cnt.map{ |c| Mint.factorial(c) }.product(1) / Mint.new(5) ** cnt.sum
  end
end
puts ans



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
# Implements [Ruby's Prime library](https://ruby-doc.com/stdlib/libdoc/prime/rdoc/Prime.html).
#
# ```
# AtCoder::Prime.first(7) # => [2, 3, 5, 7, 11, 13, 17]
# ```
  module Prime
    extend self
    include Enumerable(Int64)

    @@primes = [
    2_i64, 3_i64, 5_i64, 7_i64, 11_i64, 13_i64, 17_i64, 19_i64,
    23_i64, 29_i64, 31_i64, 37_i64, 41_i64, 43_i64, 47_i64,
    53_i64, 59_i64, 61_i64, 67_i64, 71_i64, 73_i64, 79_i64,
    83_i64, 89_i64, 97_i64, 101_i64,
    ]

    def each(&)
      index = 0
      loop do
        yield get_nth_prime(index)
        index += 1
      end
    end

    def prime_division(value : Int)
        raise DivisionByZeroError.new if value == 0

      int = typeof(value)

      factors = [] of Tuple(typeof(value), typeof(value))

      if value < 0
        value = value.abs
        factors << {int.new(-1), int.new(1)}
      end

      until prime?(value) || value == 1
        factor = value
        until prime?(factor)
          factor = find_factor(factor)
        end
        count = 0
        while value % factor == 0
          value //= factor
          count += 1
        end
        factors << {int.new(factor), int.new(count)}
      end

      if value > 1
        factors << {value, int.new(1)}
      end

      factors.sort_by! { |(factor, _)| factor }
    end

    private def find_factor(n : Int)
    # Factor of even numbers cannot be discovered by Pollard's Rho with f(x) = x^x+i
      if n.even?
        typeof(n).new(2)
      else
        pollard_rho(n).not_nil!
      end
    end

    # Get single factor by Pollard's Rho Algorithm
    private def pollard_rho(n : Int)
      typeof(n).new(1).upto(n) do |i|
        x = i
        y = pollard_random_f(x, n, i)

        loop do
          x = pollard_random_f(x, n, i)
          y = pollard_random_f(pollard_random_f(y, n, i), n, i)
          gcd = (x - y).gcd(n)

          if gcd == n
            break
          end

          if gcd != 1
            return gcd
          end
        end
      end
    end

    @[AlwaysInline]
    private def pollard_random_f(n : Int, mod : Int, seed : Int)
      (AtCoder::Math.mul_mod(n, n, mod) + seed) % mod
    end

    private def extract_prime_division_base(prime_divisions_class : Array({T, T}).class) forall T
      T
    end

    def int_from_prime_division(prime_divisions : Array({Int, Int}))
      int_class = extract_prime_division_base(prime_divisions.class)
      prime_divisions.reduce(int_class.new(1)) { |i, (factor, exponent)| i * factor ** exponent }
    end

    def prime?(value : Int)
    # Obvious patterns
        return false if value < 2
        return true if value <= 3
        return false if value.even?
        return true if value < 9

      if value < 0xffff
          return false unless typeof(value).new(30).gcd(value % 30) == 1

        7.step(by: 30, to: value) do |base|
            break if base * base > value

          if {0, 4, 6, 10, 12, 16, 22, 24}.any? { |i| value % (base + i) == 0 }
            return false
          end
        end

        return true
      end

      miller_rabin(value.to_i64)
    end

    private def miller_rabin(value)
      d = value - 1
      s = 0_i64
      until d.odd?
        d >>= 1
        s += 1
      end

      miller_rabin_bases(value).each do |base|
          next if base == value

        x = AtCoder::Math.pow_mod(base.to_i64, d, value)
          next if x == 1 || x == value - 1

        is_composite = s.times.all? do
          x = AtCoder::Math.mul_mod(x, x, value)
          x != value - 1
        end

          return false if is_composite
      end

      true
    end

    # We can reduce time complexity of Miller-Rabin tests by testing against
    # predefined bases which is enough to test against primarity in the given range.
    # https://en.wikipedia.org/wiki/Miller%E2%80%93Rabin_primality_test
    # ameba:disable Metrics/CyclomaticComplexity
    private def miller_rabin_bases(value)
      case
      when value < 1_373_653_i64
        [2, 3]
      when value < 9_080_191_i64
        [31, 73]
      when value < 25_326_001_i64
        [2, 3, 5]
      when value < 3_215_031_751_i64
        [2, 3, 5, 7]
      when value < 4_759_123_141_i64
        [2, 7, 61]
      when value < 1_122_004_669_633_i64
        [2, 13, 23, 1662803]
      when value < 2_152_302_898_747_i64
        [2, 3, 5, 7, 11]
      when value < 3_474_749_660_383_i64
        [2, 3, 5, 7, 11, 13]
      when value < 341_550_071_728_321_i64
        [2, 3, 5, 7, 11, 13, 17]
      when value < 3_825_123_056_546_413_051_i64
        [2, 3, 5, 7, 11, 13, 17, 19, 23]
      else
        [2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37]
      end
    end

    private def get_nth_prime(n)
      while @@primes.size <= n
        generate_primes
      end

      @@primes[n]
    end

    # Doubles the size of the cached prime array and performs the
    # Sieve of Eratosthenes on it.
    private def generate_primes
      new_primes_size = @@primes.size < 1_000_000 ? @@primes.size : 1_000_000
      new_primes = Array(Int64).new(new_primes_size) { |i| @@primes.last + (i + 1) * 2 }
      new_primes_max = new_primes.last

      @@primes.each do |prime|
          next if prime == 2
          break if prime * prime > new_primes_max

        # Here I use the technique of the Sieve of Sundaram. We can
        # only test against the odd multiple of the given prime.
        # min_composite is the minimum number that is greater than
        # the last confirmed prime, and is an odd multiple of
        # the given prime.
        min_multiple = ((@@primes.last // prime + 1) // 2 * 2 + 1) * prime
        min_multiple.step(by: prime * 2, to: new_primes_max) do |multiple|
          index = new_primes_size - (new_primes_max - multiple) // 2 - 1
          new_primes[index] = 0_i64
        end
      end

      @@primes.concat(new_primes.reject(0_i64))
    end

    private struct EachDivisor(T)
      include Enumerable(T)

      def initialize(@exponential_factors : Array(Array(T)))
      end

      def each(&)
        Array.each_product(@exponential_factors) do |factors|
          yield factors.reduce { |a, b| a * b }
        end
      end
    end

    # Returns an enumerator that iterates through the all positive divisors of
    # the given number. **The order is not guaranteed.**
    # Not in the original Ruby's Prime library.
    #
    # ```
    # AtCoder::Prime.each_divisor(20) do |n|
    #   puts n
    # end # => Puts 1, 2, 4, 5, 10, and 20
    #
    # AtCoder::Prime.each_divisor(10).map { |n| 1.0 / n }.to_a # => [1.0, 0.5, 0.2, 0.1]
    # ```
    def each_divisor(value : Int)
        raise ArgumentError.new unless value > 0

      factors = prime_division(value)

      if value == 1
        exponential_factors = [[value]]
      else
        exponential_factors = factors.map do |(factor, count)|
          cnt = typeof(value).zero + 1
          Array(typeof(value)).new(count + 1) do |i|
            cnt_copy = cnt
            if i < count
              cnt *= factor
            end
            cnt_copy
          end
        end
      end

      EachDivisor(typeof(value)).new(exponential_factors)
    end

    # :ditto:
    def each_divisor(value : T, &block : T ->)
      each_divisor(value).each(&block)
    end
  end
end

struct Int
  def prime?
    AtCoder::Prime.prime?(self)
  end
end

module AtCoder
# Implements [ACL's Math library](https://atcoder.github.io/ac-library/master/document_en/math.html)
  module Math
    def self.extended_gcd(a, b)
      last_remainder, remainder = a.abs, b.abs
      x, last_x, y, last_y = 0_i64, 1_i64, 1_i64, 0_i64
      while remainder != 0
        new_last_remainder = remainder
        quotient, remainder = last_remainder.divmod(remainder)
        last_remainder = new_last_remainder
        x, last_x = last_x - quotient * x, x
        y, last_y = last_y - quotient * y, y
      end

      return last_remainder, last_x * (a < 0 ? -1 : 1)
    end

    # Implements atcoder::inv_mod(value, modulo).
    def self.inv_mod(value, modulo)
      gcd, inv = extended_gcd(value, modulo)
      if gcd != 1
        raise ArgumentError.new("#{value} and #{modulo} are not coprime")
      end
      inv % modulo
    end

    # Simplified AtCoder::Math.pow_mod with support of Int64
    def self.pow_mod(base, exponent, modulo)
      if exponent == 0
        return base.class.zero + 1
      end
      if base == 0
        return base
      end
      b = exponent > 0 ? base : inv_mod(base, modulo)
      e = exponent.abs
      ret = 1_i64
      while e > 0
        if e % 2 == 1
          ret = mul_mod(ret, b, modulo)
        end
        b = mul_mod(b, b, modulo)
        e //= 2
      end
      ret
    end

    # Caluculates a * b % mod without overflow detection
    @[AlwaysInline]
    def self.mul_mod(a : Int64, b : Int64, mod : Int64)
      if mod < Int32::MAX
        return a * b % mod
      end

      # 31-bit width
      a_high = (a >> 32).to_u64
      # 32-bit width
      a_low = (a & 0xFFFFFFFF).to_u64
      # 31-bit width
      b_high = (b >> 32).to_u64
      # 32-bit width
      b_low = (b & 0xFFFFFFFF).to_u64

      # 31-bit + 32-bit + 1-bit = 64-bit
      c = a_high * b_low + b_high * a_low
      c_high = c >> 32
      c_low = c & 0xFFFFFFFF

      # 31-bit + 31-bit
      res_high = a_high * b_high + c_high
      # 32-bit + 32-bit
      res_low = a_low * b_low
      res_low_high = res_low >> 32
      res_low_low = res_low & 0xFFFFFFFF

      # Overflow
      if res_low_high + c_low >= 0x100000000
        res_high += 1
      end

      res_low = (((res_low_high + c_low) & 0xFFFFFFFF) << 32) | res_low_low

      (((res_high.to_i128 << 64) | res_low) % mod).to_i64
    end

    @[AlwaysInline]
    def self.mul_mod(a, b, mod)
      typeof(mod).new(a.to_i64 * b % mod)
    end

    # Implements atcoder::crt(remainders, modulos).
    def self.crt(remainders, modulos)
        raise ArgumentError.new unless remainders.size == modulos.size

      total_modulo = 1_i64
      answer = 0_i64

      remainders.zip(modulos).each do |(remainder, modulo)|
        gcd, p = extended_gcd(total_modulo, modulo)
        if (remainder - answer) % gcd != 0
          return 0_i64, 0_i64
        end
        tmp = (remainder - answer) // gcd * p % (modulo // gcd)
        answer += total_modulo * tmp
        total_modulo *= modulo // gcd
      end

      return answer % total_modulo, total_modulo
    end

    # Implements atcoder::floor_sum(n, m, a, b).
    def self.floor_sum(n, m, a, b)
      n, m, a, b = n.to_i64, m.to_i64, a.to_i64, b.to_i64
      res = 0_i64

      if a < 0
        a2 = a % m
        res -= n * (n - 1) // 2 * ((a2 - a) // m)
        a = a2
      end

      if b < 0
        b2 = b % m
        res -= n * ((b2 - b) // m)
        b = b2
      end

      res + floor_sum_unsigned(n, m, a, b)
    end

    private def self.floor_sum_unsigned(n, m, a, b)
      res = 0_i64

      loop do
        if a >= m
          res += n * (n - 1) // 2 * (a // m)
          a = a % m
        end

        if b >= m
          res += n * (b // m)
          b = b % m
        end

        y_max = a * n + b
          break if y_max < m

        n = y_max // m
        b = y_max % m
        m, a = a, m
      end

      res
    end

    # Returns `a * b > target`, without concern of overflows.
    def self.product_greater_than(a : Int, b : Int, target : Int)
      target // b < a
    end

    def self.get_primitive_root(p : Int)
        return 1_i64 if p == 2
      n = p - 1
      factors = AtCoder::Prime.prime_division(n)
      (2_i64..p.to_i64).each do |g|
        ok = true
        factors.each do |(factor, _)|
          if pow_mod(g, n // factor, p) == 1
            ok = false
            break
          end
        end
        if ok
          return g
        end
      end
      raise ArgumentError.new
    end
  end
end

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

        def hash(hasher)
          hasher.int(self)
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

AtCoder.static_modint(ModInt998244353, 998_244_353_i64)
alias Mint = AtCoder::ModInt998244353
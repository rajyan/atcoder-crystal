require "atcoder/mod_int"

alias Mint = AtCoder::ModInt998244353

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

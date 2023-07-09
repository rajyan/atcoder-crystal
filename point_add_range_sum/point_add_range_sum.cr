n, q = read_line.split.map(&.to_i)

rbst = RBST(Int32, Int64).new
a = read_line.split.map(&.to_i)
a.each_with_index { |a, i| rbst.insert(LazyNode(Int32, Int64).new(key: i, val: a.to_i64)) }

q.times do
  t, l, r = read_line.split.map(&.to_i)
  if t == 1
    puts rbst[l...r].not_nil!.as(LazyNode(Int32, Int64)).acc
  else
    rbst.apply(l, l + 1, r.to_i64)
  end
end

class RBST(T, K)
  @root : Node(T)? = nil
  getter :root
  @comp : (T, T) -> Bool = ->(a : T, b : T) { a > b }

  def initialize(a : Array(T) = [] of T, &@comp : (T, T) -> Bool)
    a.each { |e| insert(e) }
  end

  def initialize(a : Array(T) = [] of T, @comp = ->(a : T, b : T) { a > b })
    a.each { |e| insert(e) }
  end

  def size
    @root.try(&.size) || 0
  end

  def height
    @root.try(&.height) || 0
  end

  def insert(v : T)
    @root = insert(v, @root)
  end

  def insert(v : T, node : Node(T)?) : Node(T)
    return Node(T).new(v) unless node

    left, right = split(node, rank(v))
    merge(merge(left, Node(T).new(v)), right).not_nil!
  end

  def insert(n : Node(T)) : Node(T)
    return @root = n unless @root

    left, right = split(@root, rank(n.key))
    @root = merge(merge(left, n), right).not_nil!
  end

  def <<(v : T)
    insert(v)
  end

  def delete(v : T)
    @root = delete(v, @root)
  end

  def delete(v : T, node : Node(T)?) : Node(T)?
    return nil unless node

    left, mid = split(node, rank(v))
    w, right = split(mid, 1)
    return nil if w.try(&.key) != v
    merge(left, right)
  end

  def clear
    @root = nil
  end

  def search(v : T, node : Pointer(Node(T)?) = pointerof(@root)) : Node(T)?
    n = nth(rank(v), node)
    n.try(&.key) == v ? n : nil
  end

  def lower_than(v : T, node : Pointer(Node(T)?) = pointerof(@root)) : Node(T)?
    left, right = split(node.value, rank(v))
    ret = left.try(&.last)
    node.value = merge(left, right) # restore
    ret
  end

  def <(v : T)
    lower_than(v)
  end

  def higher_than(v : T, node : Pointer(Node(T)?) = pointerof(@root)) : Node(T)?
    left, right = split(node.value, rank(v))
    ret = right.try(&.first)
    node.value = merge(left, right) # restore
    ret
  end

  def >=(v : T)
    higher_than(v)
  end

  def rank(v : T, node : Node(T)? = @root)
    idx = 0
    until node.nil?
      node = if @comp.call(v, node.key)
               idx += (node.left.try(&.size) || 0) + 1
               node.right
             else
               node.left
             end
    end
    idx
  end

  def nth(n : Int32, node : Pointer(Node(T)?) = pointerof(@root)) : Node(T)?
    range(n, n + 1, node)
  end

  # returned node's left, right property is not safe to use
  def range(l : Int32, r : Int32, node : Pointer(Node(T)?) = pointerof(@root))
    return nil unless node

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
  def split(node : Node(T)?, k : Int32) : {Node(T)?, Node(T)?}
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

  def merge(left : Node(T)?, right : Node(T)?) : Node(T)?
    return right || left if right.nil? || left.nil?

    left.propagate
    right.propagate
    if rand(left.size + right.size) < left.size
      left.right = merge(left.right, right)
      left.fix
    else
      right.left = merge(left, right.left)
      right.fix
    end
  end

  def apply(l : Int32, r : Int32, x : K, node : Pointer(Node(T)?) = pointerof(@root))
    mid, right = split(node.value, r)
    left, mid = split(mid, l)
    mid.try &.apply(x)
    node.value = merge(merge(left, mid), right).not_nil! # restore
  end
end

class Node(T)
  @left : Node(T)?
  @right : Node(T)?

  property :left, :right
  getter :key, :size, :height

  def initialize(@key : T, @size : Int32 = 1, @height : Int32 = 1); end

  def propagate; end

  def apply(x : _); end

  def fix
    @size = (@left.try(&.size) || 0) + (@right.try(&.size) || 0) + 1
    @height = {@left.try(&.height) || 0, @right.try(&.height) || 0}.max + 1
    self
  end

  def first
    left.try(&.first) || self
  end

  def last
    right.try(&.last) || self
  end
end

class LazyNode(T, K) < Node(T)
  @val : K?; @acc : K?; @lazy : K?
  property :val, :acc, :lazy

  def initialize(@key : T, @size : Int32 = 1, @height : Int32 = 1, @val : K? = nil); end

  def propagate
    super
    return unless @lazy

    left.try &.apply(@lazy)
    right.try &.apply(@lazy)
    @val = map(@val, @lazy)
    @lazy = nil
  end

  def fix
    @acc = op(@left.try &.as(self).acc, op(@right.try &.as(self).acc, @val))
    super
  end

  def apply(lz : K?)
    @lazy = compose(@lazy, lz)
    @acc = map(@acc, @lazy)
  end

  macro handle_identity(a, b)
    return {{a}} unless {{b}}
    return {{b}} unless {{a}}
  end

  def op(a : K?, b : K?) : K?
    handle_identity(a, b)
    a + b
  end

  def map(a : K?, b : K?) : K?
    handle_identity(a, b)
    a + b
  end

  def compose(a : K?, b : K?)
    handle_identity(a, b)
    a + b
  end
end

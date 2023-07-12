n, m = read_line.split.map(&.to_i)
p = read_line.split.map(&.to_i).sort
l = read_line.split.map(&.to_i)
d = read_line.split.map(&.to_i)

tree = RBST(Int32, Nil).new(p)
ans = p.map(&.to_i64).sum
ld = l.zip(d).sort_by { |(l, d)| -d }
ld.each do |(l, d)|
  min = tree >= l
  next unless min
  tree.delete(min.key)
  ans -= d
end

puts ans

class RBST(KeyType, Monoid)
  @root : Node(KeyType, Monoid)? = nil
  getter :root
  @comp : (KeyType, KeyType) -> Bool = ->(a : KeyType, b : KeyType) { a > b }
  @@rand = Random.new

  def initialize(a : Array(KeyType) = [] of KeyType, &@comp : (KeyType, KeyType) -> Bool)
    a.each { |e| insert(e) }
  end

  def initialize(a : Array(KeyType) = [] of KeyType, @comp = ->(a : KeyType, b : KeyType) { a > b })
    a.each { |e| insert(e) }
  end

  def size
    @root.try(&.size) || 0
  end

  def height
    @root.try(&.height) || 0
  end

  def insert(v : KeyType)
    @root = insert(v, @root)
  end

  def insert(v : KeyType, node : Node(KeyType, Monoid)?) : Node(KeyType, Monoid)
    return Node(KeyType, Monoid).new(v) unless node

    left, right = split(node, rank(v))
    merge(merge(left, Node(KeyType, Monoid).new(v)), right).not_nil!
  end

  def insert(n : Node(KeyType, Monoid)) : Node(KeyType, Monoid)
    return @root = n unless @root

    left, right = split(@root, rank(n.key))
    @root = merge(merge(left, n), right).not_nil!
  end

  def <<(v : KeyType)
    insert(v)
  end

  def delete(v : KeyType)
    @root = delete(v, @root)
  end

  def delete(v : KeyType, node : Node(KeyType, Monoid)?) : Node(KeyType, Monoid)?
    return nil unless node

    left, mid = split(node, rank(v))
    w, right = split(mid, 1)
    return nil if w.try(&.key) != v
    merge(left, right)
  end

  def clear
    @root = nil
  end

  def first(node : Node(KeyType, Monoid)?)
    return nil unless node
    first(node.left) || node
  end

  def last(node : Node(KeyType, Monoid)?)
    return nil unless node
    last(node.right) || node
  end

  def search(v : KeyType, node : Pointer(Node(KeyType, Monoid)?) = pointerof(@root)) : Node(KeyType, Monoid)?
    n = nth(rank(v), node)
    n.try(&.key) == v ? n : nil
  end

  def lower_than(v : KeyType, node : Pointer(Node(KeyType, Monoid)?) = pointerof(@root)) : Node(KeyType, Monoid)?
    left, right = split(node.value, rank(v))
    ret = last(left)
    node.value = merge(left, right) # restore
    ret
  end

  def <(v : KeyType)
    lower_than(v)
  end

  def higher_than(v : KeyType, node : Pointer(Node(KeyType, Monoid)?) = pointerof(@root)) : Node(KeyType, Monoid)?
    left, right = split(node.value, rank(v))
    ret = first(right)
    node.value = merge(left, right) # restore
    ret
  end

  def >=(v : KeyType)
    higher_than(v)
  end

  def rank(v : KeyType, node : Node(KeyType, Monoid)? = @root)
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

  def nth(n : Int32, node : Pointer(Node(KeyType, Monoid)?) = pointerof(@root)) : Node(KeyType, Monoid)?
    range(n, n + 1, node)
  end

  # returned node's left, right property is not safe to use
  def range(l : Int32, r : Int32, node : Pointer(Node(KeyType, Monoid)?) = pointerof(@root))
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
  def split(node : Node(KeyType, Monoid)?, k : Int32) : {Node(KeyType, Monoid)?, Node(KeyType, Monoid)?}
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

  def merge(left : Node(KeyType, Monoid)?, right : Node(KeyType, Monoid)?) : Node(KeyType, Monoid)?
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

  def apply(l : Int32, r : Int32, x : _, node : Pointer(Node(KeyType, Monoid)?) = pointerof(@root))
    mid, right = split(node.value, r)
    left, mid = split(mid, l)
    mid.try &.apply(x)
    node.value = merge(merge(left, mid), right) # restore
  end
end

class Node(KeyType, Monoid)
  @left : Node(KeyType, Monoid)?
  @right : Node(KeyType, Monoid)?

  property :left, :right, :m
  getter :key, :size, :height

  def initialize(@key : KeyType, @m : Monoid? = nil, @size : Int32 = 1, @height : Int32 = 1); end

  def propagate; end

  def apply(x : _); end

  def fix
    @size = (@left.try(&.size) || 0) + (@right.try(&.size) || 0) + 1
    @height = {@left.try(&.height) || 0, @right.try(&.height) || 0}.max + 1
    self
  end
end

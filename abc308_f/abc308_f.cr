n, m = read_line.split.map(&.to_i)
p = read_line.split.map(&.to_i).sort
l = read_line.split.map(&.to_i)
d = read_line.split.map(&.to_i)

tree = RBST(Int32, Void).new(p)
ans = p.map(&.to_i64).sum
ld = l.zip(d).sort_by { |(l, d)| -d }
ld.each do |(l, d)|
  min = tree >= l
  next unless min
  tree.delete(min.key)
  ans -= d
end

puts ans

class RBST(T, K)
  @root : Node(T, K)? = nil
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

  def insert(v : T, node : Node(T, K)?) : Node(T, K)
    return Node(T, K).new(v) unless node

    left, right = split(node, rank(v))
    merge(merge(left, Node(T, K).new(v)), right).not_nil!
  end

  def <<(v : T)
    insert(v)
  end

  def delete(v : T)
    @root = delete(v, @root)
  end

  def delete(v : T, node : Node(T, K)?) : Node(T, K)?
    return nil unless node

    left, mid = split(node, rank(v))
    w, right = split(mid, 1)
    return nil if w.try(&.key) != v
    merge(left, right)
  end

  def clear
    @root = nil
  end

  def search(v : T, node : Pointer(Node(T, K)?) = pointerof(@root)) : Node(T, K)?
    n = nth(rank(v), node)
    n.try(&.key) == v ? n : nil
  end

  def lower_than(v : T, node : Pointer(Node(T, K)?) = pointerof(@root)) : Node(T, K)?
    left, right = split(node.value, rank(v))
    ret = left.try(&.last)
    node.value = merge(left, right) # restore
    ret
  end

  def <(v : T)
    lower_than(v)
  end

  def higher_than(v : T, node : Pointer(Node(T, K)?) = pointerof(@root)) : Node(T, K)?
    left, right = split(node.value, rank(v))
    ret = right.try(&.first)
    node.value = merge(left, right) # restore
    ret
  end

  def >=(v : T)
    higher_than(v)
  end

  def rank(v : T, node : Node(T, K) = @root) : Int32
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

  def nth(n : Int32, node : Pointer(Node(T, K)?) = pointerof(@root)) : Node(T, K)?
    range(n, n + 1, node)
  end

  def range(l : Int32, r : Int32, node : Pointer(Node(T, K)?) = pointerof(@root))
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
  def split(node : Node(T, K)?, k : Int32) : {Node(T, K)?, Node(T, K)?}
    return {nil, nil} unless node
    raise IndexError.new("k: #{k} is out of tree range") unless 0 <= k <= node.size

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

  def merge(left : Node(T, K)?, right : Node(T, K)?) : Node(T, K)?
    return right unless left
    return left unless right

    if rand(left.size + right.size) < left.size
      left.right = merge(left.right, right)
      left.fix
    else
      right.left = merge(left, right.left)
      right.fix
    end
  end
end

class Node(T, K)
  @left : Node(T, K)?
  @right : Node(T, K)?
  @val : K?; @acc : K?; @lazy : K?
  property :left, :right, :val, :acc, :lazy
  getter :key, :size, :height

  def initialize(@key : T, @size : Int32 = 1, @height : Int32 = 1, @val = nil, @acc = nil, @lazy = nil); end

  def propagate
  end

  def fix
    @size = (@left.try(&.size) || 0) + (@right.try(&.size) || 0) + 1
    @height = {@left.try(&.height) || 0, @right.try(&.height) || 0}.max + 1
    self
  end

  def dup
    n = Node(T, K).new(key, size, height)
    n.left, n.right = left.dup, right.dup
    n
  end

  def first
    left.try(&.first) || self
  end

  def last
    right.try(&.last) || self
  end
end

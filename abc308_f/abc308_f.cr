n, m = read_line.split.map(&.to_i)
p = read_line.split.map(&.to_i).sort
l = read_line.split.map(&.to_i)
d = read_line.split.map(&.to_i)

tree = RBST(Int32).new(p)
ans = p.map(&.to_i64).sum
ld = l.zip(d).sort_by { |(l, d)| -d }
ld.each do |(l, d)|
  min = tree >= l
  next unless min
  tree.delete(min.key)
  ans -= d
end

puts ans

class RBST(T)
  @@rand = Random.new
  @root : Node(T)? = nil
  getter :root
  @comp : (T, T) -> Bool = ->(a : T, b : T) { a > b }

  def initialize(a : Array(T) = [] of T, &@comp : (T, T) -> Bool)
    a.each { |e| insert(e) }
  end

  def initialize(a : Array(T) = [] of T)
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

  def <<(v : T)
    insert(v)
  end

  def delete(v : T)
    @root = delete(v, @root)
  end

  def delete(v : T, node : Node(T)?) : Node(T)?
    return nil unless node

    if @comp.call(node.key, v)
      node.left = delete(v, node.left)
    elsif @comp.call(v, node.key)
      node.right = delete(v, node.right)
    else
      return merge(node.left, node.right)
    end
    node.fix
  end

  def search(v : T, node : Node(T) = @root) : Node(T)?
    until node.nil?
      node = if @comp.call(node.key, v)
               node.left
             elsif @comp.call(v, node.key)
               node.right
             else
               return node
             end
    end
  end

  def lower_than(v : T, node : Node(T) = @root) : Node(T)?
    ret = nil
    until node.nil?
      node = if @comp.call(node.key, v)
               node.left
             else
               ret = node
               node.right
             end
    end
    ret
  end

  def <=(v : T)
    lower_than(v)
  end

  def higher_than(v : T, node : Node(T) = @root) : Node(T)?
    ret = nil
    until node.nil?
      node = if @comp.call(v, node.key)
               node.right
             else
               ret = node
               node.left
             end
    end
    ret
  end

  def >=(v : T)
    higher_than(v)
  end

  def rank(v : T, node : Node(T) = @root) : Int32
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

  def nth(n : Int32, node : Node(T) = @root) : Node(T)
    raise IndexError.new("k: #{k} is out of tree range") unless 0 <= k <= node.size
    until node.nil?
      idx = node.left.try(&.size) || 0
      return node.not_nil! if idx == n
      node = if idx > n
               node.left
             else
               n -= idx + 1
               node.right
             end
    end
  end

  def [](n : Int32)
    nth(n)
  end

  # {[0...k], [k...n]}
  def split(node : Node(T)?, k : Int32) : {Node(T)?, Node(T)?}
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

  def merge(left : Node(T)?, right : Node(T)?) : Node(T)?
    return right || left if right.nil? || left.nil?

    if @@rand.rand(left.size + right.size) < left.size
      left.right = merge(left.right, right)
      left.fix
    else
      right.left = merge(left, right.left)
      right.fix
    end
  end
end

class Node(T)
  @left : Node(T)?
  @right : Node(T)?

  property :left, :right
  getter :key, :size, :height

  def initialize(@key : T, @size : Int32 = 1, @height : Int32 = 1); end

  def fix
    @size = (@left.try(&.size) || 0) + (@right.try(&.size) || 0) + 1
    @height = {@left.try(&.height) || 0, @right.try(&.height) || 0}.max + 1
    self
  end
end

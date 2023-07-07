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
  tree.delete(min)
  ans -= d
end

puts ans

class RBST(T)
  @root : Node(T) | Nil = nil
  getter :root
  @comp : (T, T) -> Bool = ->(a : T, b : T) { a > b }

  def initialize(a : Array(T) = [] of T)
    a.each { |e| insert(e) }
  end

  def initialize(a : Array(T) = [] of T, &block)
    a.each { |e| insert(e) }
    @comp = block
  end

  def insert(v : T)
    @root = insert_node(@root, v)
  end

  def <<(v : T)
    insert(v)
  end

  def delete(v : T) : Node(T) | Nil
    @root = delete_node(@root, v)
  end

  def clear
    @root = nil
  end

  def search(v : T) : Node(T) | Nil
    node = @root
    until node.nil?
      node = if @comp.call(node.val, v)
               node.left
             elsif @comp.call(v, node.val)
               node.right
             else
               return node
             end
    end
    node
  end

  def <=(v : T) : T | Nil
    node = @root
    ret = nil
    until node.nil?
      node = if @comp.call(node.val, v)
               node.left
             else
               ret = node.val
               node.right
             end
    end
    ret
  end

  def >=(v : T) : T | Nil
    node = @root
    ret = nil
    until node.nil?
      node = if @comp.call(v, node.val)
               node.right
             else
               ret = node.val
               node.left
             end
    end
    ret
  end

  def rank(v : T) : Int32
    node = @root
    idx = 0
    until node.nil?
      node = if v <= node.val
               node = node.left
             else
               idx += (node.left.try(&.size) || 0) + 1
               node = node.right
             end
    end
    idx
  end

  def nth(n : Int32) : Node(T) | Nil
    node = @root
    until node.nil?
      idx = node.left.try(&.size) || 0
        return node if idx == n
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

  def size
    @root.try(&.size) || 0
  end

  def height
    @root.try(&.height) || 0
  end

  private def insert_node(node : Node(T) | Nil, v : T) : Node(T)
    return Node(T).new(v) unless node

    left, right = split(node, rank(v))
    merge(merge(left, Node(T).new(v)), right).not_nil!
  end

  private def delete_node(node : Node(T) | Nil, v : T) : Node(T) | Nil
    return nil unless node

    if @comp.call(node.val, v)
      node.left = delete_node(node.left, v)
    elsif @comp.call(v, node.val)
      node.right = delete_node(node.right, v)
    else
      return merge(node.left, node.right)
    end
    node.fix
  end

  private def split(node : Node(T) | Nil, k : Int32) : {Node(T) | Nil, Node(T) | Nil}
    return {nil, nil} unless node

    sz = node.left.try(&.size) || 0
    if k <= sz
      left, right = split(node.left, k)
      node.left, right = right, node
      {left, right.fix}
    else
      left, right = split(node.right, k - sz - 1)
      node.right, left = left, node
      {left.fix, right}
    end
  end

  private def merge(left : Node(T) | Nil, right : Node(T) | Nil) : Node(T) | Nil
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

  private def rotate_right(node : Node(T)) : Node(T)
    top = node.left.not_nil!
    top.right, node.left = node, top.right
    node.fix
    top.fix
  end

  private def rotate_left(node : Node(T)) : Node(T)
    top = node.right.not_nil!
    top.left, node.right = node, top.left
    node.fix
    top.fix
  end
end

class Node(T) < Reference
  @left : Node(T) | Nil
  @right : Node(T) | Nil
  property :left, :right
  getter :val, :size, :height

  def initialize(@val : T)
    @left = nil
    @right = nil
    @size = 1
    @height = 1
  end

  def fix
    @size = (@left.try(&.size) || 0) + (@right.try(&.size) || 0) + 1
    @height = {@left.try(&.height) || 0, @right.try(&.height) || 0}.max + 1
    self
  end
end

n, q = read_line.split.map(&.to_i)
a = read_line.split.map(&.to_i)

rbst = RBST(Int32).new(a)

def tree_dump(top)
  return STDERR.puts "empty" unless top
  top = top.dup
  a = Array.new(top.height * 2) { Array.new(top.size * 2) { " " } }
  a[0][0] = top.key.to_s + "(#{top.not_nil!.size})"
  cnt = 0
  dfs = uninitialized typeof(top) -> String | Nil
  dfs = ->(now : typeof(top)) {
    if nl = now.left
      a[(top.height - nl.height) * 2 - 1][cnt] = "|"
      a[(top.height - nl.height) * 2][cnt] = nl.key.to_s + "(#{nl.not_nil!.size})"
      dfs.call(nl)
    end
    if nr = now.right
      cnt += 2
      a[(top.height - nr.height) * 2 - 1][cnt - 1] = "\\"
      a[(top.height - nr.height) * 2][cnt] = nr.key.to_s + "(#{nl.not_nil!.size})"
      dfs.call(nr)
    end
  }
  dfs.call(top)
  STDERR.puts a.map(&.join).join('\n')
end

tree_dump rbst.root

q.times do
  l, r, k = read_line.split.map(&.to_i)
  tree_dump rbst.split(rbst.root, r)[0]
end

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

  def size
    @root.try(&.size) || 0
  end

  def height
    @root.try(&.height) || 0
  end

  def insert(v : T)
    @root = insert(v, @root)
  end

  def insert(v : T, node : Node(T) | Nil) : Node(T)
    return Node(T).new(v) unless node

    left, right = split(node, index(v))
    merge(merge(left, Node(T).new(v)), right).not_nil!
  end

  def <<(v : T)
    insert(v)
  end

  def delete(v : T)
    @root = delete(v, @root)
  end

  def delete(v : T, node : Node(T) | Nil) : Node(T) | Nil
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

  def clear
    @root = nil
  end

  def search(v : T, node : Node(T) = @root) : Node(T) | Nil
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

  def lower_than(v : T, node : Node(T) = @root) : T | Nil
    ret = nil
    until node.nil?
      node = if @comp.call(node.key, v)
               node.left
             else
               ret = node.key
               node.right
             end
    end
    ret
  end

  def <=(v : T)
    lower_than(v)
  end

  def higher_than(v : T, node : Node(T) = @root) : T | Nil
    ret = nil
    until node.nil?
      node = if @comp.call(v, node.key)
               node.right
             else
               ret = node.key
               node.left
             end
    end
    ret
  end

  def >=(v : T)
    higher_than(v)
  end

  def index(v : T, node : Node(T) = @root) : Int32
    idx = 0
    until node.nil?
      node = if v <= node.key
               node.left
             else
               idx += (node.left.try(&.size) || 0) + 1
               node.right
             end
    end
    idx
  end

  def nth(n : Int32, node : Node(T) = @root) : Node(T) | Nil
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

  def split(node : Node(T) | Nil, k : Int32) : {Node(T) | Nil, Node(T) | Nil}
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

  def merge(left : Node(T) | Nil, right : Node(T) | Nil) : Node(T) | Nil
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
  getter :key, :size, :height

  def initialize(@key : T)
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

n, m = read_line.split.map(&.to_i)
p = read_line.split.map(&.to_i).sort
l = read_line.split.map(&.to_i)
d = read_line.split.map(&.to_i)

tree = RBST(Int32).new
p.each { |p| tree << p }

ans = p.map(&.to_i64).sum
ld = l.zip(d).sort_by { |(l, d)| -d }
ld.each do |(l, d)|
  min = tree.higher_than(l)
  next unless min
  tree.delete(min)
  ans -= d
end

macro dump(*vs)
  {% unless flag?(:release) %}
    {% for v in vs %}
      STDERR.puts {{v.stringify}} + "=#{{{v}}}"
    {% end %}
  {% end %}
end

dump tree.to_s

puts ans

class RBST(T)
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

    def to_s(io : IO)
      a = Array.new(height * 10) { Array.new(size * 5) { " " } }
      a[0][0] = val.to_s
      dump val.to_s
      l = 0

      dfs = uninitialized Node(T) -> String | Nil
      dfs = ->(now : Node(T)) {
        if now.left
          dump now.height * 2
          a[(10-now.height) * 2 - 1][l] = "|"
          a[(10-now.height) * 2][l] = now.val.to_s
          dfs.call(now.left.not_nil!)
        end
        if now.right
          l += 1
          dump now.height * 2
          a[(10-now.height) * 2 - 1][l] = "\\"
          a[(10-now.height) * 2][l] = now.val.to_s
          dfs.call(now.right.not_nil!)
        end
      }
      dfs.call(self)
      dump a.map(&.join)
    end
  end

  @root : Node(T) | Nil = nil

  def initialize(a : Array(T) = [] of T, &block)
    a.each{ |e| insert(e) }

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

  def search(v : T) : Node(T) | Nil
    node = @root
    until node.nil? || v == node.val
      node = v < node.val ? node.left : node.right
    end
    node
  end

  def clear
    @root = nil
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

  def lower_than(v : T) : T | Nil
    node = @root
    ret = nil
    until node.nil?
      node = if node.val <= v
               ret = node.val
               node.right
             else
               node.left
             end
    end
    ret
  end

  def higher_than(v : T) : T | Nil
    node = @root
    ret = nil
    until node.nil?
      node = if node.val >= v
               ret = node.val
               node.left
             else
               node.right
             end
    end
    ret
  end

  def size
    @root.try(&.size) || 0
  end

  def height
    @root.try(&.height) || 0
  end

  def to_s(io : IO)
    @root.try(&.to_s) || ""
  end

  private def insert_node(node : Node(T) | Nil, v : T) : Node(T)
    return Node(T).new(v) unless node
    return insert_root(node, v) if rand(node.size + 1) == 0

    if v < node.val
      node.left = insert_node(node.left, v)
    else
      node.right = insert_node(node.right, v)
    end
    node.fix
  end

  private def insert_root(node : Node(T) | Nil, v : T) : Node(T)
    return Node(T).new(v) unless node

    if v < node.val
      node.left = insert_root(node.left, v)
      rotate_right(node)
    else
      node.right = insert_root(node.right, v)
      rotate_left(node)
    end
  end

  private def delete_node(node : Node(T) | Nil, v : T) : Node(T) | Nil
    return nil unless node
    return meld(node.left, node.right) if v == node.val

    if v < node.val
      node.left = delete_node(node.left, v)
    else
      node.right = delete_node(node.right, v)
    end
    node.fix
  end

  private def meld(left : Node(T) | Nil, right : Node(T) | Nil) : Node(T) | Nil
    return right unless left
    return left unless right

    if rand(left.size + right.size) < left.size
      left.right = meld(left.right, right)
      left.fix
    else
      right.left = meld(left, right.left)
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

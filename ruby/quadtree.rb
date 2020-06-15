
class Point
  attr_accessor :x, :y

  def initialize(x, y)
    @x = x
    @y = y
  end

  def ==(other)
    return x == other.x && y == other.y
  end

  def to_s
    return "(#{x}, #{y})"
  end

  def distance_to(other)
    Math.sqrt(((x - other.x) ** 2) + ((y - other.y) ** 2))
  end
end

class Rectangle
  attr_accessor :center, :width, :height

  def initialize(center, width, height)
    @center = center
    @width = width
    @height = height
  end

  def x()
    return @center.x
  end

  def y()
    return @center.y
  end

  def contains(other)
    ((other.x > (self.x() - self.width)) && (other.x < (self.x() + self.width)) && (other.y > (self.y() - self.height)) && (other.y < (self.y() + self.height)))
  end

  def intersects(other)
    not(other.x() - other.width > self.x() + self.width || other.x() + other.width < self.x() - self.width || other.y() - other.height > self.y() + self.height || other.y() + other.height < self.y() - self.height)
  end
end

class Quadtree
  attr_reader :points

  def initialize(x, y, w, h, capacity)
    @bounds = Rectangle.new(Point.new(x, y), w, h)
    @points = []
    @tl = nil
    @tr = nil
    @bl = nil
    @br = nil
    @split = false
    @capacity = capacity
  end

  def contains(other)
    @bounds.contains(other)
  end

  def intersects(other)
    @bounds.intersects(other)
  end

  def has_children
    @split
  end

  def insert(p)
    if @points.count == @capacity
      if !has_children()
        divide()
      end
      if @tl.contains(p)
        @tl.insert(p)
      elsif @tr.contains(p)
        @tr.insert(p)
      elsif @bl.contains(p)
        @bl.insert(p)
      elsif @br.contains(p)
        @br.insert(p)
      else
        raise ValueError("No subtree found 4 point {}".format(p))
      end
    else
      self.points.append(p)
    end
  end

  def query(r)
    found = []
    if not intersects(r)
      return found
    else
      for p in self.points
        if r.contains(p)
          found.push(p)
        end
      end
      if has_children()
        r1 = @tl.query(r)
        r2 = @tr.query(r)
        r3 = @bl.query(r)
        r4 = @br.query(r)

        for p in r1
          found.push(p)
        end
        for p in r2
          found.push(p)
        end
        for p in r3
          found.push(p)
        end
        for p in r4
          found.push(p)
        end
      end
    end

    found
  end

  def divide()
    @tl = Quadtree.new(
      @bounds.x() - @bounds.width / 2.0,
      @bounds.y() - @bounds.height / 2.0,
      @bounds.width / 2.0,
      @bounds.height / 2.0,
      @capacity,
    )
    @tr = Quadtree.new(
      @bounds.x() + @bounds.width / 2.0,
      @bounds.y() - @bounds.height / 2.0,
      @bounds.width / 2.0,
      @bounds.height / 2.0,
      @capacity,
    )
    @bl = Quadtree.new(
      @bounds.x() - @bounds.width / 2.0,
      @bounds.y() + @bounds.height / 2.0,
      @bounds.width / 2.0,
      @bounds.height / 2.0,
      @capacity,
    )
    @br = Quadtree.new(
      @bounds.x() + @bounds.width / 2.0,
      @bounds.y() + @bounds.height / 2.0,
      @bounds.width / 2.0,
      @bounds.height / 2.0,
      @capacity,
    )
    @split = true
  end

  def clear()
    @points = []
    @tl = nil
    @tr = nil
    @bl = nil
    @br = nil
    @split = false
  end
end

# about 2 times faster than python finishing in half the time for the same number of points
# still about 5 times slower than C++ and Rust
TOTAL_POINTS = 2000

def main()
  w = 200.0
  h = 200.0
  qt = Quadtree.new w / 2.0, h / 2.0, w / 2.0, h / 2.0, 4
  points = []

  5.times do |i|
    TOTAL_POINTS.times do
      x = rand * w
      y = rand * h
      p = Point.new x, y
      qt.insert p
      points.push p
    end

    count = 0
    for point in points
      r = Rectangle.new(Point.new(point.x, point.y), 10.0, 10.0)
      for other in qt.query(r)
        if point != other and point.distance_to(other) < 3.0
          count += 1
        end
      end
    end
    puts "Round #{i}: Found #{count} overlapping points"
    qt.clear
    points = []
  end
end

main()

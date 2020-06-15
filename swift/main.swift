import Foundation

struct Point: Equatable {
  public static func == (lhs: Point, rhs: Point) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y
  }

  let x: Double
  let y: Double

  init(x: Double, y: Double) {
    self.x = x
    self.y = y
  }

  func distance(to other: Point) -> Double {
    sqrt(pow(other.x - x, 2) + pow(other.y - y, 2))
  }
}

struct Rectangle {
  let center: Point
  let width: Double
  let height: Double

  init(center: Point, width: Double, height: Double) {
    self.center = center
    self.width = width
    self.height = height
  }

  var x: Double { center.x }
  var y: Double { center.y }

  func contains(point other: Point) -> Bool {
    (other.x > (self.x - self.width))
      && (other.x < (self.x + self.width))
      && (other.y > (self.y - self.height))
      && (other.y < (self.y + self.height))
  }

  func intersects(rectangle other: Rectangle) -> Bool {
    !(other.x - other.width > self.x + self.width
      || other.x + other.width < self.x - self.width
      || other.y - other.height > self.y + self.height
      || other.y + other.height < self.y - self.height)
  }
}

class Quadtree {
  let bounds: Rectangle
  var points: [Point] = []
  var top_left: Quadtree! = nil
  var top_right: Quadtree! = nil
  var bottom_left: Quadtree! = nil
  var bottom_right: Quadtree! = nil
  var split: Bool = false
  var capacity: UInt64

  init(x: Double, y: Double, w: Double, h: Double, capacity: UInt64) {
    self.bounds = Rectangle(center: Point(x: x, y: y), width: w, height: h)
    self.capacity = capacity
  }

  func contains(_ point: Point) -> Bool {
    bounds.contains(point: point)
  }

  func intersects(_ rectangle: Rectangle) -> Bool {
    bounds.intersects(rectangle: rectangle)
  }
  func has_children() -> Bool {
    self.split
  }


  func insert(_ p: Point) {
    if points.count == capacity {
      if !has_children() {
        divide()
      }
      if top_left.contains(p) {
        top_left.insert(p)
      } else if top_right.contains(p) {
        top_right.insert(p)
      } else if bottom_left.contains(p) {
        bottom_left.insert(p)
      } else if bottom_right.contains(p) {
        bottom_right.insert(p)
      } else {
        fatalError("Insert could not find a subtree to insert into");
      }
    } else {
      points.append(p);
    }
  }


  func query(_ r: Rectangle) -> [Point] {
    var found = [Point]()
    if !self.intersects(r) {
      return found;
    } else {
      for p in points {
        if r.contains(point: p) {
          found.append(p);
        }
      }
      if self.has_children() {
        let r1 = self.top_left.query(r);
        let r2 = self.top_right.query(r);
        let r3 = self.bottom_left.query(r);
        let r4 = self.bottom_right.query(r);

        for p in r1 {
          found.append(p);
        }
        for p in r2 {
          found.append(p);
        }
        for p in r3 {
          found.append(p);
        }
        for p in r4 {
          found.append(p);
        }
      }
      return found;
    }
  }


  func divide() {
    self.top_left = Quadtree(
      x: self.bounds.x - self.bounds.width / 2.0,
      y: self.bounds.y - self.bounds.height / 2.0,
      w: self.bounds.width / 2.0,
      h: self.bounds.height / 2.0,
      capacity: self.capacity
    );
    self.top_right = Quadtree(
      x:self.bounds.x + self.bounds.width / 2.0,
      y:self.bounds.y - self.bounds.height / 2.0,
      w:self.bounds.width / 2.0,
      h:self.bounds.height / 2.0,
      capacity:self.capacity
    );
    self.bottom_left = Quadtree(
      x:self.bounds.x - self.bounds.width / 2.0,
      y:self.bounds.y + self.bounds.height / 2.0,
      w:self.bounds.width / 2.0,
      h:self.bounds.height / 2.0,
      capacity:self.capacity
    );
    self.bottom_right = Quadtree(
      x:self.bounds.x + self.bounds.width / 2.0,
      y:self.bounds.y + self.bounds.height / 2.0,
      w:self.bounds.width / 2.0,
      h:self.bounds.height / 2.0,
      capacity:self.capacity
    );
    self.split = true;
  }

  func clear() {
    points = []
    self.top_left?.clear();
    self.top_right?.clear();
    self.bottom_left?.clear();
    self.bottom_right?.clear();
    self.split = false;
  }

}

func main() {
  // about 2 times slower than rust which itself is approximately 1.5 times slower than c++
  // this is very likely because I am just unfamiliar with rust and swift compared to c++
  // perhaps i could be making more optimizations and writing better code in swift and rust
  // for example when i made Point and Rectangle classes instead of structs it slowed down to
  // 4 times slower than rust and when I made everything a struct including Quadtree it was about
  // 3 times slower than rust. However, when Point and Rectangle are structs Quadtree is a class
  // (which to me seems like a very natural arrangement) performance is--as i said--2x worse
  let total_points = 20000;
  let w = 200.0;
  let h = 200.0;
  let qt = Quadtree(x: w / 2.0,y: h / 2.0,w: w / 2.0,h: h / 2.0, capacity: 4);
  var points = [Point]()

  for i in 0..<5 {
    for _ in 0..<total_points {
      let x = Double.random(in: 0..<w)
      let y = Double.random(in: 0..<h)
      let p = Point(x: x, y: y)
      qt.insert(p);
      points.append(p)
    }

    var count = 0;
    for point in points {
      let r = Rectangle(
        center: Point(
          x: point.x,
          y: point.y
        ),
        width: 10.0,
        height: 10.0
      );
      // for other in &points {
      for other in qt.query(r) {
        if point != other && point.distance(to: other) < 3.0 {
          count += 1;
        }
      }
    }
    print("Round \(i): Found \(count) overlapping points");
    qt.clear();
    points = []
  }
}

main()

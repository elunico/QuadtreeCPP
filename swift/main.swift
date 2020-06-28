import Foundation

struct Point: Equatable {
    let x: Double
    let y: Double

    func distance(to other: Point) -> Double {
        sqrt(pow(other.x - x, 2) + pow(other.y - y, 2))
    }
}

struct Rectangle: Equatable {
    let center: Point
    let width: Double
    let height: Double

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

    func contains(point: Point) -> Bool {
        bounds.contains(point: point)
    }

    func intersects(area: Rectangle) -> Bool {
        bounds.intersects(rectangle: area)
    }

    var has_children: Bool { self.split }

    func insert(point p: Point) {
        if points.count == capacity {
            if !has_children {
                divide()
            }
            if top_left.contains(point: p) {
                top_left.insert(point: p)
            } else if top_right.contains(point: p) {
                top_right.insert(point: p)
            } else if bottom_left.contains(point: p) {
                bottom_left.insert(point: p)
            } else if bottom_right.contains(point: p) {
                bottom_right.insert(point: p)
            } else {
                fatalError("Insert could not find a subtree to insert into")
            }
        } else {
            points.append(p)
        }
    }

    func query(area r: Rectangle) -> [Point] {
        var found: [Point] = []
        if !self.intersects(area: r) {
            return found
        } else {
            found.append(contentsOf: points.filter { r.contains(point: $0) })
            if self.has_children {
                found.append(contentsOf: self.top_left.query(area: r))
                found.append(contentsOf: self.top_right.query(area: r))
                found.append(contentsOf: self.bottom_left.query(area: r))
                found.append(contentsOf: self.bottom_right.query(area: r))
            }
            return found
        }
    }

    func points(around point: Point, within radius: Double) -> [Point] {
        query(area: Rectangle(center: Point(x: point.x, y: point.y), width: radius, height: radius)).filter(point.overlaps)
    }

    func divide() {
        self.top_left = Quadtree(
            x: self.bounds.x - self.bounds.width / 2.0,
            y: self.bounds.y - self.bounds.height / 2.0,
            w: self.bounds.width / 2.0,
            h: self.bounds.height / 2.0,
            capacity: self.capacity
        )
        self.top_right = Quadtree(
            x:self.bounds.x + self.bounds.width / 2.0,
            y:self.bounds.y - self.bounds.height / 2.0,
            w:self.bounds.width / 2.0,
            h:self.bounds.height / 2.0,
            capacity:self.capacity
        )
        self.bottom_left = Quadtree(
            x:self.bounds.x - self.bounds.width / 2.0,
            y:self.bounds.y + self.bounds.height / 2.0,
            w:self.bounds.width / 2.0,
            h:self.bounds.height / 2.0,
            capacity:self.capacity
        )
        self.bottom_right = Quadtree(
            x:self.bounds.x + self.bounds.width / 2.0,
            y:self.bounds.y + self.bounds.height / 2.0,
            w:self.bounds.width / 2.0,
            h:self.bounds.height / 2.0,
            capacity:self.capacity
        )
        self.split = true
    }

    func clear() {
        points = []
        self.top_left?.clear()
        self.top_right?.clear()
        self.bottom_left?.clear()
        self.bottom_right?.clear()
        self.split = false
    }

}

extension Point {
    func overlaps(_ other: Point) -> Bool {
        self != other && self.distance(to: other) < 3.0
    }
}

func main() {
    let total_points = 20000
    let w = 200.0
    let h = 200.0
    let qt = Quadtree(x: w / 2.0, y: h / 2.0, w: w / 2.0, h: h / 2.0, capacity: 4)
    var points: [Point] = []

    for i in 0..<5 {
        for _ in 0..<total_points {
            let x = Double.random(in: 0..<w)
            let y = Double.random(in: 0..<h)
            let p = Point(x: x, y: y)
            qt.insert(point: p)
            points.append(p)
        }

        let count = points.map { qt.points(around: $0, within: 10.0).count }.reduce(0, +)

        print("Round \(i): Found \(count) overlapping points")
        qt.clear()
        points = []
    }
}

main()

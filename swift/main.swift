import Foundation

infix operator ∈

func ∈(lhs: Point, rhs: Rectangle) -> Bool {
    (lhs.x > (rhs.x - rhs.width))
        && (lhs.x < (rhs.x + rhs.width))
        && (lhs.y > (rhs.y - rhs.height))
        && (lhs.y < (rhs.y + rhs.height))
}

func ∈(lhs: Point, rhs: Quadtree) -> Bool {
    lhs ∈ rhs.bounds
}

infix operator ⋂

func ⋂(lhs: Rectangle, rhs: Rectangle) -> Bool {
    !(rhs.x - rhs.width > lhs.x + lhs.width
        || rhs.x + rhs.width < lhs.x - lhs.width
        || rhs.y - rhs.height > lhs.y + lhs.height
        || rhs.y + rhs.height < lhs.y - lhs.height)

}

func ⋂(lhs: Rectangle, rhs: Quadtree) -> Bool {
    lhs ⋂ rhs.bounds
}

func ⋂(lhs: Quadtree, rhs: Rectangle) -> Bool {
    lhs.bounds ⋂ rhs
}

func ⋂(lhs: Quadtree, rhs: Quadtree) -> Bool {
    lhs.bounds ⋂ rhs.bounds
}


prefix operator !!!
prefix func !!! (message: @autoclosure () -> String) -> Never {
    fatalError(message())
}

precedencegroup ListTransformOperatorPrecedence {
    higherThan: ListReductionOperatorPrecedence
    lowerThan: MultiplicationPrecedence
    associativity: left
}

infix operator => : ListTransformOperatorPrecedence

func => <T, R> (lhs: [T], rhs: (T) -> R) -> [R] {
    return lhs.map(rhs)
}

infix operator |> : ListTransformOperatorPrecedence

func |> <T>(lhs: [T], rhs: (T) -> Bool) -> [T] {
    lhs.filter(rhs)
}

precedencegroup ListReductionOperatorPrecedence {
    higherThan: AdditionPrecedence
    associativity: left
}

infix operator >* : ListReductionOperatorPrecedence

func >* <T, S> (lhs: [T], rhs: (initialValue: S, reduction: (S, T) -> S)) -> S {
    lhs.reduce(rhs.initialValue, rhs.reduction)
}

func >* <T> (lhs: [T], rhs: (T, T) -> T) -> T {
    lhs.reduce(rhs)
}

extension Array {
    func reduce(_ reduction: (Element, Element) -> Element) -> Element {
        var proxy = self
        return proxy.reduce(proxy.removeFirst(), reduction)
    }
}

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
}

precedencegroup ListAppendPrecedence {
    lowerThan: FunctionArrowPrecedence
    associativity: left
}

infix operator <- : ListAppendPrecedence

@discardableResult
func <- (lhs: Quadtree, rhs: Point) -> Quadtree {
    if lhs.points.count == lhs.capacity {
        if !lhs.has_children {
            lhs.divide()
        }
        if rhs ∈ lhs.top_left {
            lhs.top_left <- rhs
        } else if rhs ∈ lhs.top_right {
            lhs.top_right <- rhs
        } else if rhs ∈ lhs.bottom_left {
            lhs.bottom_left <- rhs
        } else if rhs ∈ lhs.bottom_right {
            lhs.bottom_right <- rhs
        } else {
            !!!"Insert could not find a subtree to insert into"
        }
    } else {
        lhs.points <- rhs
    }
    return lhs
}

@discardableResult
func <- <Element>(lhs: inout [Element], rhs: Element) -> [Element] {
    lhs.append(rhs)
    return lhs
}

infix operator <<- : ListAppendPrecedence

func <<- <Element>(lhs: inout [Element], rhs: [Element]) {
    lhs.append(contentsOf: rhs)
}

infix operator |&|

func |&| (lhs: Point, rhs: Point) -> Bool {
    lhs != rhs && lhs.distance(to: rhs) < 3.0
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

    var has_children: Bool { self.split }

    func query(area r: Rectangle) -> [Point] {
        var found: [Point] = []
        if !(self ⋂ r) {
            return found
        } else {
            found.append(contentsOf: points |> { $0 ∈ r })
            if self.has_children {
                found <<- self.top_left.query(area: r)
                found <<- self.top_right.query(area: r)
                found <<- self.bottom_left.query(area: r)
                found <<- self.bottom_right.query(area: r)
            }
            return found
        }
    }

    func points(around point: Point, within radius: Double) -> [Point] {
        query(area: Rectangle(center: Point(x: point.x, y: point.y), width: radius, height: radius)) |> { point |&| $0 }
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
            x: self.bounds.x + self.bounds.width / 2.0,
            y: self.bounds.y - self.bounds.height / 2.0,
            w: self.bounds.width / 2.0,
            h: self.bounds.height / 2.0,
            capacity: self.capacity
        )
        self.bottom_left = Quadtree(
            x: self.bounds.x - self.bounds.width / 2.0,
            y: self.bounds.y + self.bounds.height / 2.0,
            w: self.bounds.width / 2.0,
            h: self.bounds.height / 2.0,
            capacity: self.capacity
        )
        self.bottom_right = Quadtree(
            x: self.bounds.x + self.bounds.width / 2.0,
            y: self.bounds.y + self.bounds.height / 2.0,
            w: self.bounds.width / 2.0,
            h: self.bounds.height / 2.0,
            capacity: self.capacity
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
            qt <- p
            points <- p
        }

        let count = points => { qt.points(around: $0, within: 10.0).count } >* (+)

        print("Round \(i): Found \(count) overlapping points");
        qt.clear();
        points = []
    }
}

main()

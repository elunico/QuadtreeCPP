package main

import (
	"fmt"
	"math"
	"math/rand"
)

type Point struct {
	x float64
	y float64
}

func (p *Point) DistanceTo(other *Point) float64 {
	return math.Sqrt(math.Pow(p.x-other.x, 2.0) + math.Pow(p.y-other.y, 2.0))
}

type Rectangle struct {
	center Point
	width  float64
	height float64
}

func (r *Rectangle) x() float64 {
	return r.center.x
}

func (r *Rectangle) y() float64 {
	return r.center.y
}

func (r *Rectangle) contains(point *Point) bool {
	return (point.x > (r.x() - r.width)) &&
		(point.x < (r.x() + r.width)) &&
		(point.y > (r.y() - r.height)) &&
		(point.y < (r.y() + r.height))
}

func (r *Rectangle) intersects(other *Rectangle) bool {
	return !(other.x()-other.width > r.x()+r.width ||
		other.x()+other.width < r.x()-r.width ||
		other.y()-other.height > r.y()+r.height ||
		other.y()+other.height < r.y()-r.height)
}

type Quadtree struct {
	bounds      Rectangle
	points      []Point
	topLeft     *Quadtree
	topRight    *Quadtree
	bottomLeft  *Quadtree
	bottomRight *Quadtree
	split       bool
	capacity    int
}

func (qt *Quadtree) contains(other *Point) bool {
	return qt.bounds.contains(other)
}

func (qt *Quadtree) intersects(other *Rectangle) bool {
	return qt.bounds.intersects(other)
}

func (qt *Quadtree) hasChildren() bool {
	return qt.split
}

func (qt *Quadtree) insert(p Point) {
	if len(qt.points) == qt.capacity {
		if !qt.hasChildren() {
			qt.divide()
		}
		if qt.topLeft.contains(&p) {
			qt.topLeft.insert(p)
		} else if qt.topRight.contains(&p) {
			qt.topRight.insert(p)
		} else if qt.bottomLeft.contains(&p) {
			qt.bottomLeft.insert(p)
		} else if qt.bottomRight.contains(&p) {
			qt.bottomRight.insert(p)
		} else {
			panic("Insert could not find a subtree to insert into")
		}
	} else {
		qt.points = append(qt.points, p)
	}
}

func (qt *Quadtree) query(r *Rectangle) []Point {
	if !qt.intersects(r) {
		return nil
	}
	found := make([]Point, 0, 100)
	for _, p := range qt.points {
		if r.contains(&p) {
			found = append(found, p)
		}
	}
	if qt.hasChildren() {
		r1 := qt.topLeft.query(r)
		r2 := qt.topRight.query(r)
		r3 := qt.bottomLeft.query(r)
		r4 := qt.bottomRight.query(r)

		// can be nil, range nil is legal

		for _, p := range r1 {
			found = append(found, p)
		}
		for _, p := range r2 {
			found = append(found, p)
		}
		for _, p := range r3 {
			found = append(found, p)
		}
		for _, p := range r4 {
			found = append(found, p)
		}

	}
	return found
}

func newQuadtree(x, y, w, h float64, capacity int) *Quadtree {
	center := Point{x, y}
	bounds := Rectangle{center, w, h}
	tree := new(Quadtree)
	tree.bounds = bounds
	tree.points = make([]Point, 0, 100)
	tree.topLeft = nil
	tree.topRight = nil
	tree.bottomLeft = nil
	tree.bottomRight = nil
	tree.split = false
	tree.capacity = capacity
	return tree
}

func (qt *Quadtree) divide() {
	qt.topLeft = newQuadtree(
		qt.bounds.x()-qt.bounds.width/2.0,
		qt.bounds.y()-qt.bounds.height/2.0,
		qt.bounds.width/2.0,
		qt.bounds.height/2.0,
		qt.capacity,
	)
	qt.topRight = newQuadtree(
		qt.bounds.x()+qt.bounds.width/2.0,
		qt.bounds.y()-qt.bounds.height/2.0,
		qt.bounds.width/2.0,
		qt.bounds.height/2.0,
		qt.capacity,
	)
	qt.bottomLeft = newQuadtree(
		qt.bounds.x()-qt.bounds.width/2.0,
		qt.bounds.y()+qt.bounds.height/2.0,
		qt.bounds.width/2.0,
		qt.bounds.height/2.0,
		qt.capacity,
	)
	qt.bottomRight = newQuadtree(
		qt.bounds.x()+qt.bounds.width/2.0,
		qt.bounds.y()+qt.bounds.height/2.0,
		qt.bounds.width/2.0,
		qt.bounds.height/2.0,
		qt.capacity,
	)
	qt.split = true
}

func (qt *Quadtree) clear() {
	qt.points = make([]Point, 0, 100)
	qt.topLeft = nil
	qt.topRight = nil
	qt.bottomLeft = nil
	qt.bottomRight = nil
	qt.split = false
}

func main() {
	TOTAL_POINTS := 20000
	w := 200.0
	h := 200.0
	qt := newQuadtree(w/2.0, h/2.0, w/2.0, h/2.0, 4)
	points := make([]Point, 0, 100)

	for i := 0; i < 5; i++ {

		for i := 0; i < TOTAL_POINTS; i++ {
			x := rand.Float64() * w
			y := rand.Float64() * h
			p := Point{x, y}
			qt.insert(p)
			points = append(points, p)
		}

		countChannel := make(chan int)
		// FIXME: if TOTAL_POINTS is not divisible by 10 we will ignore some
		// since it is 20000 this is ok for now
		stride := int(TOTAL_POINTS / 10)
		// last := TOTAL_POINTS % 10
		// one more goroutine needed if TOTAL_POINTS is not divisible by 10

		for batch := 0; batch < 10; batch++ {
			go (func(b int) {
				count := 0
				for j := (b * stride); j < ((b + 1) * stride); j++ {
					if j >= len(points) {
						fmt.Printf("Illegal j %d: b %d, stride %d len points %d\n", j, b, stride, len(points))
					}
					r := Rectangle{
						Point{
							points[j].x,
							points[j].y,
						},
						10.0,
						10.0,
					}
					for _, other := range qt.query(&r) {
						if points[j].DistanceTo(&other) < 3.0 {
							count++
						}
					}
				}
				countChannel <- count
			})(batch)
		}

		bigCount := 0
		for i := 0; i < 10; i++ {
			icnt := <-countChannel
			bigCount += icnt
		}
		close(countChannel)

		fmt.Printf("Round %d: Found %d overlapping points\n", i, bigCount)
		qt.clear()
		points = make([]Point, 0, 100)
	}
}

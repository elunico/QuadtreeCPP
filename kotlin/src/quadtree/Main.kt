package quadtree

const val TOTAL_POINTS = 20000



fun main() {
    val w = 200.0
    val h = 200.0
    val qt = Quadtree(w / 2.0, h / 2.0, w / 2.0, h / 2.0, 4)
    val points = mutableListOf<Point>()
    repeat(4) { i ->
        repeat(TOTAL_POINTS) {
            val x = Math.random() * w
            val y = Math.random() * h
            val p = Point(x, y)
            qt insert p
            points.add(p)
        }
        var count: Long = 0
        for (point in points) {
            val r = Rectangle(Point(point.x, point.y), 10.0, 10.0)
            // for other in &points {
            count += qt.query(r)
                .asSequence()
                .filter { point != it && point distanceTo it < 3.0 }
                .count()
        }
        println("Round $i: Found $count overlapping points")
        qt.clear()
        points.clear()
    }

}


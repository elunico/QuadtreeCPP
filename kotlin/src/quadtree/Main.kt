package quadtree

import kotlin.time.ExperimentalTime
import kotlin.time.measureTimedValue

const val TOTAL_POINTS = 20000

@ExperimentalTime
fun main() {
    val w = 200.0
    val h = 200.0
    val qt = Quadtree(w / 2.0, h / 2.0, w / 2.0, h / 2.0, 4)
    val points = mutableListOf<Point>()
    var iterations = 0
    measureTimedValue {
        repeat(4) {
            repeat(TOTAL_POINTS) {
                val x = Math.random() * w
                val y = Math.random() * h
                val p = Point(x, y)
                qt insert p
                points.add(p)
            }

            val count = points.fold(0L) { acc, point ->
                qt.query(Rectangle(Point(point.x, point.y), 10.0, 10.0)).filter(point::overlaps).count() + acc
            }

            println("Round $iterations: Found $count overlapping points")
            qt.clear()
            points.clear()
            iterations++
        }
    }.also(::println)
}

private infix fun Point.overlaps(it: Point) = this != it && this distanceTo it < 3.0


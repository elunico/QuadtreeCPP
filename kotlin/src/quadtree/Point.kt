package quadtree

import kotlin.math.pow
import kotlin.math.sqrt

data class Point(var x: Double, var y: Double) {

    infix fun distanceTo(other: Point) = sqrt((x - other.x).pow(2.0) + (y - other.y).pow(2.0))

}

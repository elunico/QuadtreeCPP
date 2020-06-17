package quadtree

import kotlin.math.pow
import kotlin.math.sqrt

class Point(var x: Double, var y: Double) {

    infix fun distanceTo(other: Point) = sqrt((x - other.x).pow(2.0) + (y - other.y).pow(2.0))
    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Point

        if (x != other.x) return false
        if (y != other.y) return false

        return true
    }

    override fun hashCode(): Int {
        var result = x.hashCode()
        result = 31 * result + y.hashCode()
        return result
    }
}

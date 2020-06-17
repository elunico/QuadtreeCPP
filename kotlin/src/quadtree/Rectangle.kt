package quadtree

class Rectangle(var center: Point, var width: Double, var height: Double) {
    operator fun contains(p: Point) =
        p.x > x - width && p.x < x + width &&
                p.y > y - height && p.y < y + height

    val x: Double
        get() = center.x

    val y: Double
        get() = center.y

    fun intersects(r: Rectangle): Boolean {
        return !(r.x - r.width > x + width ||
                r.x + r.width < x - width ||
                r.y - r.height > y + height ||
                r.y + r.height < y - height)
    }

    override fun equals(other: Any?): Boolean {
        if (this === other) return true
        if (javaClass != other?.javaClass) return false

        other as Rectangle

        if (center != other.center) return false
        if (width != other.width) return false
        if (height != other.height) return false

        return true
    }

    override fun hashCode(): Int {
        var result = center.hashCode()
        result = 31 * result + width.hashCode()
        result = 31 * result + height.hashCode()
        return result
    }

}

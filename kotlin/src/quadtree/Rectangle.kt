package quadtree

data class Rectangle(var center: Point, var width: Double, var height: Double) {
    operator fun contains(p: Point) =
        p.x > x - width && p.x < x + width &&
                p.y > y - height && p.y < y + height

    val x: Double
        get() = center.x

    val y: Double
        get() = center.y

    infix fun intersects(r: Rectangle): Boolean {
        return !(r.x - r.width > x + width ||
                r.x + r.width < x - width ||
                r.y - r.height > y + height ||
                r.y + r.height < y - height)
    }


}

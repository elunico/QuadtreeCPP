package quadtree

class Quadtree(x: Double, y: Double, w: Double, h: Double, var capacity: Int) {
    val bounds: Rectangle = Rectangle(Point(x, y), w, h)
    private var points: MutableList<Point> = mutableListOf()
    private var topLeft: Quadtree? = null
    private var topRight: Quadtree? = null
    private var bottomLeft: Quadtree? = null
    private var bottomRight: Quadtree? = null
    private var split = false

    operator fun contains(point: Point): Boolean {
        return bounds.contains(point)
    }

    infix fun intersects(area: Rectangle): Boolean {
        return bounds.intersects(area)
    }

    val hasChildren: Boolean
        get() = split

    infix fun insert(p: Point) {
        if (points.size == capacity) {
            if (!hasChildren) {
                divide()
            }
            if (topLeft?.contains(p) == true) {
                topLeft?.insert(p)
            } else if (topRight?.contains(p) == true) {
                topRight?.insert(p)
            } else if (bottomLeft?.contains(p) == true) {
                bottomLeft?.insert(p)
            } else if (bottomRight?.contains(p) == true) {
                bottomRight?.insert(p)
            } else {
                throw RuntimeException(
                    "Insert could not find a subtree to insert into"
                )
            }
        } else {
            points.add(p)
        }
    }

    infix fun query(r: Rectangle): MutableList<Point> {
        val found = mutableListOf<Point>()
        if (intersects(r)) {
            found.addAll(points.filter(r::contains))
            if (hasChildren) {
                topLeft?.apply { found.addAll(query(r)) }
                topRight?.apply { found.addAll(query(r)) }
                bottomLeft?.apply { found.addAll(query(r)) }
                bottomRight?.apply { found.addAll(query(r)) }
            }
        }
        return found
    }

    private fun divide() {
        topLeft = Quadtree(
            bounds.x - bounds.width / 2.0,
            bounds.y - bounds.height / 2.0,
            bounds.width / 2.0,
            bounds.height / 2.0,
            capacity
        )
        topRight = Quadtree(
            bounds.x + bounds.width / 2.0,
            bounds.y - bounds.height / 2.0,
            bounds.width / 2.0,
            bounds.height / 2.0,
            capacity
        )
        bottomLeft = Quadtree(
            bounds.x - bounds.width / 2.0,
            bounds.y + bounds.height / 2.0,
            bounds.width / 2.0,
            bounds.height / 2.0,
            capacity
        )
        bottomRight = Quadtree(
            bounds.x + bounds.width / 2.0,
            bounds.y + bounds.height / 2.0,
            bounds.width / 2.0,
            bounds.height / 2.0,
            capacity
        )
        split = true
    }

    fun clear() {
        points = mutableListOf()
        topLeft?.clear()
        topRight?.clear()
        bottomLeft?.clear()
        bottomRight?.clear()
        split = false
    }

}

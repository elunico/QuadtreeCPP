package quadtree

fun Boolean.then(block: () -> Unit): Boolean = if (this) this.apply { block() } else this
fun Boolean.ifFalse(block: () -> Unit): Boolean = if (!this) this.apply { block() } else this

class Quadtree(x: Double, y: Double, w: Double, h: Double, var capacity: Int) {
    val bounds: Rectangle = Rectangle(Point(x, y), w, h)
    private var points: MutableList<Point> = mutableListOf()
    private var topLeft: Quadtree? = null
    private var topRight: Quadtree? = null
    private var bottomLeft: Quadtree? = null
    private var bottomRight: Quadtree? = null
    private var split = false

    operator fun contains(point: Point) = point in bounds

    infix fun intersects(area: Rectangle) = bounds intersects area

    val hasChildren: Boolean
        get() = split

    infix fun insert(p: Point) {
        if (points.size == capacity) {
            if (!hasChildren) {
                divide()
            }
            topLeft?.contains(p)?.then { topLeft?.insert(p) }
            topRight?.contains(p)?.then { topRight?.insert(p) }
            bottomLeft?.contains(p)?.then { bottomLeft?.insert(p) }
            bottomRight?.contains(p)?.then { bottomRight?.insert(p) }
        } else {
            points.add(p)
        }
    }

    infix fun query(r: Rectangle): MutableList<Point> {
        val found = mutableListOf<Point>()
        if (this intersects r) {
            found.addAll(points.filter { it in r })
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

    public fun pointsOverlapping(p: Point, radius: Double): List<Point> {
        return this.query(Rectangle(Point(p.x, p.y), radius, radius)).filter(p::overlaps)
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

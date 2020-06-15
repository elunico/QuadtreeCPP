package quadtree;

import java.util.*;

public class Quadtree {
     Rectangle bounds;
     ArrayList<Point> points = new ArrayList<>();
     Quadtree top_left;
     Quadtree  top_right;
     Quadtree bottom_left;
     Quadtree  bottom_right;
     boolean  split;
     int capacity;

    public Quadtree(double x, double y, double w, double h, int capacity) {
        this.bounds = new Rectangle(new Point(x, y),  w,  h);
        this.capacity = capacity;
    }

    public boolean contains(Point point) {
        return bounds.contains( point);
    }

    public boolean intersects(Rectangle area) {
        return bounds.intersects(area);
    }

    public boolean hasChildren()  {
        return this.split;
    }

    public void insert(Point p) {
        if (points.size() == capacity) {
            if (!hasChildren()) {
                divide();
            }
            if (top_left.contains(p)) {
                top_left.insert(p);
            } else if (top_right.contains(p)) {
                top_right.insert(p);
            } else if (bottom_left.contains(p)) {
                bottom_left.insert(p);
            } else if (bottom_right.contains(p)) {
                bottom_right.insert(p);
            } else {
                throw new RuntimeException("Insert could not find a subtree to insert into");
            }
        } else {
            points.add(p);
        }
    }

    public ArrayList<Point> query(Rectangle r) {
        ArrayList<Point> found = new ArrayList<Point>();
        if (!this.intersects(r)) {
            return found;
        } else {
            for (Point p: points) {
                if (r.contains(p)) {
                    found.add(p);
                }
            }
            if (this.hasChildren()) {
                ArrayList<Point> r1 = this.top_left.query(r);
                ArrayList<Point> r2 = this.top_right.query(r);
                ArrayList<Point> r3 = this.bottom_left.query(r);
                ArrayList<Point> r4 = this.bottom_right.query(r);

                for (Point p : r1) {
                    found.add(p);
                }
                for (Point p : r2) {
                    found.add(p);
                }
                for (Point p : r3) {
                    found.add(p);
                }
                for (Point p : r4) {
                    found.add(p);
                }
            }
            return found;
        }
    }


    private void divide() {
        this.top_left = new Quadtree(
             this.bounds.x() - this.bounds.width / 2.0,
             this.bounds.y() - this.bounds.height / 2.0,
             this.bounds.width / 2.0,
             this.bounds.height / 2.0,
             this.capacity
        );
        this.top_right = new Quadtree(
            this.bounds.x() + this.bounds.width / 2.0,
            this.bounds.y() - this.bounds.height / 2.0,
            this.bounds.width / 2.0,
            this.bounds.height / 2.0,
            this.capacity
        );
        this.bottom_left = new Quadtree(
            this.bounds.x() - this.bounds.width / 2.0,
            this.bounds.y() + this.bounds.height / 2.0,
            this.bounds.width / 2.0,
            this.bounds.height / 2.0,
            this.capacity
        );
        this.bottom_right = new Quadtree(
            this.bounds.x() + this.bounds.width / 2.0,
            this.bounds.y() + this.bounds.height / 2.0,
            this.bounds.width / 2.0,
            this.bounds.height / 2.0,
            this.capacity
        );
        this.split = true;
    }

    public void clear() {
        points = new ArrayList<>();
        if (this.top_left != null) this.top_left.clear();
        if (this.top_right != null) this.top_right.clear();
        if (this.bottom_left != null) this.bottom_left.clear();
        if (this.bottom_right != null) this.bottom_right.clear();
        this.split = false;
    }

}

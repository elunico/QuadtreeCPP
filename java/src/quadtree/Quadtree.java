package quadtree;

import org.jetbrains.annotations.*;

import java.time.*;
import java.util.ArrayList;

import static java.util.Objects.requireNonNull;
import static java.util.stream.Collectors.toCollection;

public class Quadtree {
    @NotNull Rectangle bounds;
    @NotNull ArrayList<@NotNull Point> points = new ArrayList<>();
    @Nullable Quadtree top_left;
    @Nullable Quadtree top_right;
    @Nullable Quadtree bottom_left;
    @Nullable Quadtree bottom_right;
    boolean split;
    int capacity;
    
    public Quadtree(double x, double y, double w, double h, int capacity) {
        this.bounds = new Rectangle(new Point(x, y), w, h);
        this.capacity = capacity;
    }
    
    public boolean contains(@NotNull final Point point) {
        return bounds.contains(point);
    }
    
    public boolean intersects(@NotNull final Rectangle area) {
        return bounds.intersects(area);
    }
    
    public boolean hasChildren() {
        return this.split;
    }
    
    public void insert(@NotNull final Point p) {
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
                throw new RuntimeException(
                  "Insert could not find a subtree to insert into");
            }
        } else {
            points.add(p);
        }
    }
    
    
    private void repeatFor(Duration time, Runnable block) {
        var end = LocalDateTime.now().plus(time);
        while (LocalDateTime.now().isBefore(end)) {
            block.run();
        }
    }
    
    @NotNull
    public ArrayList<@NotNull Point> query(@NotNull final Rectangle r) {
        ArrayList<Point> found = new ArrayList<Point>();
        if (this.intersects(r)) {
            found.addAll(points.stream()
                               .filter(r::contains)
                               .collect(toCollection(ArrayList::new)));
            if (this.hasChildren()) {
                ArrayList<Point> r1 = requireNonNull(this.top_left).query(r);
                ArrayList<Point> r2 = requireNonNull(this.top_right).query(r);
                ArrayList<Point> r3 = requireNonNull(this.bottom_left).query(r);
                ArrayList<Point> r4 = requireNonNull(this.bottom_right).query(r);
                
                found.addAll(r1);
                found.addAll(r2);
                found.addAll(r3);
                found.addAll(r4);
            }
        }
        return found;
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
        if (this.top_left != null) {
            this.top_left.clear();
        }
        if (this.top_right != null) {
            this.top_right.clear();
        }
        if (this.bottom_left != null) {
            this.bottom_left.clear();
        }
        if (this.bottom_right != null) {
            this.bottom_right.clear();
        }
        this.split = false;
    }
    
}

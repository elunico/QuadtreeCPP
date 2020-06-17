package quadtree;

import org.jetbrains.annotations.NotNull;

public class Rectangle {
    @NotNull
    public Point center;
    public double width;
    public double height;
    
    public Rectangle(@NotNull Point center, double width, double height) {
        this.center = center;
        this.width = width;
        this.height = height;
    }
    
    @Override
    public boolean equals(Object o) {
        if (this == o) {
            return true;
        }
        if (o == null || getClass() != o.getClass()) {
            return false;
        }
        
        Rectangle rectangle = (Rectangle) o;
        
        if (Double.compare(rectangle.width, width) != 0) {
            return false;
        }
        if (Double.compare(rectangle.height, height) != 0) {
            return false;
        }
        return center.equals(rectangle.center);
    }
    
    @Override
    public int hashCode() {
        int result;
        long temp;
        result = center.hashCode();
        temp = Double.doubleToLongBits(width);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        temp = Double.doubleToLongBits(height);
        result = 31 * result + (int) (temp ^ (temp >>> 32));
        return result;
    }
    
    public boolean contains(@NotNull final Point p) {
        return (p.x > (x() - w())) && (p.x < (x() + w())) &&
               (p.y > (y() - h())) &&
               (p.y < (y() + h()));
    }
    
    public double x() { return center.x; }
    
    public double y() { return center.y; }
    
    public double w() { return width; }
    
    public double h() { return height; }
    
    public boolean intersects(@NotNull final Rectangle r) {
        return !(((r.x() - r.w()) > (x() + w())) ||
                 ((r.x() + r.w()) < (x() - w())) ||
                 ((r.y() - r.h()) > (y() + h())) ||
                 ((r.y() + r.h()) < (y() - h())));
    }
}

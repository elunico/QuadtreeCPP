package quadtree;

public class Rectangle {
  public Point center;
  public double width;
  public double height;

  public Rectangle(Point center, double width, double height) {
    this.center = center;
    this.width = width;
    this.height = height;
  }

  public double x() { return center.x;  }
  public double y() { return center.y; }
  public double w() { return width; }
  public double h() { return height; }

  public boolean contains(final Point p) {
    return (p.x > (x() - w())) && (p.x < (x() + w())) && (p.y > (y() - h())) &&
          (p.y < (y() + h()));
  }

  public boolean intersects(final Rectangle r) {
    return !(((r.x() - r.w()) > (x() + w())) || ((r.x() + r.w()) < (x() - w())) ||
            ((r.y() - r.h()) > (y() + h())) || ((r.y() + r.h()) < (y() - h())));
  }
}

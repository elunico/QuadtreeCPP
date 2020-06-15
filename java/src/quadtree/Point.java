package quadtree;

public class Point {
  public double x, y;

  public Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  public double distanceTo(Point other) {
    return Math.sqrt(Math.pow(x - other.x, 2) + Math.pow(y - other.y, 2));
  }
}

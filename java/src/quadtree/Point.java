package quadtree;

import org.jetbrains.annotations.NotNull;

public class Point {
  
  @Override
  public boolean equals(Object o) {
    if (this == o) {
      return true;
    }
    if (o == null || getClass() != o.getClass()) {
      return false;
    }
    
    Point point = (Point) o;
    
    if (Double.compare(point.x, x) != 0) {
      return false;
    }
    return Double.compare(point.y, y) == 0;
  }
  
  @Override
  public int hashCode() {
    int result;
    long temp;
    temp = Double.doubleToLongBits(x);
    result = (int) (temp ^ (temp >>> 32));
    temp = Double.doubleToLongBits(y);
    result = 31 * result + (int) (temp ^ (temp >>> 32));
    return result;
  }
  
  public double x, y;

  public Point(double x, double y) {
    this.x = x;
    this.y = y;
  }

  public double distanceTo(@NotNull Point other) {
    return Math.sqrt(Math.pow(x - other.x, 2) + Math.pow(y - other.y, 2));
  }
}

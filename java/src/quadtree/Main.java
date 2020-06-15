package quadtree;
import java.util.*;

public class Main {
  public static void main(String []args) {
    int total_points = 20000;
    double w = 200.0;
    double h = 200.0;
    Quadtree qt = new Quadtree(w / 2.0, h / 2.0, w / 2.0, h / 2.0, 4);
    ArrayList<Point> points = new ArrayList<>();

    for (int i = 0; i < 5; i++) {
        for (int j = 0; j < total_points; j++) {
            double x = Math.random() * w;
            double y = Math.random() * h;
            Point p = new Point(x, y);
            qt.insert(p);
            points.add(p);
        }

        long count = 0;
        for (Point point: points) {
            Rectangle r = new Rectangle(new Point(point.x, point.y), 10.0, 10.0);
            // for other in &points {
            for (Point other : qt.query(r)) {
                if (point != other && point.distanceTo(other) < 3.0) {
                    count += 1;
                }
            }
        }
        System.out.println("Round " + i + ": Found " + count + " overlapping points");
        qt.clear();
        points.clear();
    }
  }
}

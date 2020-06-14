#include "Point.h"
#include "cmath"

std::ostream &operator<<(std::ostream &os, Point const &p) {
  os << "(" << p.x << ", " << p.y << ")";
  return os;
}

double Point::distance_to(Point const &other) const {
  return sqrt(pow(x - other.x, 2.0) + pow(y - other.y, 2.0));
}

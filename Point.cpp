#include "Point.h"

std::ostream &operator<<(std::ostream &os, Point const &p) {
  os << "Point(" << p.x << ", " << p.y << ")";
  return os;
}

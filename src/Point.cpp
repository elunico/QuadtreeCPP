#include "Point.h"

std::ostream &operator<<(std::ostream &os, Point const &p) {
  os << "(" << p.x << ", " << p.y << ")";
  return os;
}

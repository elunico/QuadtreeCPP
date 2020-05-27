#ifndef POINT_H
#define POINT_H

#include <iostream>
#include <sstream>
#include <string>
#include <vector>

struct Point {
  const double x;
  const double y;

  Point() : x(0), y(0) {}
  Point(double x_, double y_) : x(x_), y(y_) {}

  std::string description() const {
    std::ostringstream s{};
    s << "Point(" << x << ", " << y << ")";
    return s.str();
  }
};

std::ostream &operator<<(std::ostream &os, Point const &p);
#endif

#ifndef POINT_H
#define POINT_H

#include <iostream>
#include <vector>

struct Point {
  const double x;
  const double y;

  Point() : x(0), y(0) {}
  Point(double x_, double y_) : x(x_), y(y_) {}
};

std::ostream &operator<<(std::ostream &os, Point const &p);
#endif

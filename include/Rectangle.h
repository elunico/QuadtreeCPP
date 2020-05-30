#ifndef RECTANGLE_H
#define RECTANGLE_H

#include "Point.h"

class Rectangle {
private:
  double x_, y_, w_, h_;

public:
  Rectangle();
  Rectangle(double x, double y, double w, double h);

  bool contains(Point const &p) const noexcept;

  bool intersects(Rectangle const &r) const noexcept;

  double x() const noexcept;
  double y() const noexcept;
  double w() const noexcept;
  double h() const noexcept;
};

#endif

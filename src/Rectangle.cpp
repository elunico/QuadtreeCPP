#include "Rectangle.h"

Rectangle::Rectangle() : x_(0), y_(0), w_(0), h_(0) {}
Rectangle::Rectangle(double x, double y, double w, double h)
    : x_(x), y_(y), w_(w), h_(h) {}

bool Rectangle::contains(Point const &p) const noexcept {
  return (p.x > (x_ - w_)) && (p.x < (x_ + w_)) && (p.y > (y_ - h_)) &&
         (p.y < (y_ + h_));
}

bool Rectangle::intersects(Rectangle const &r) const noexcept {
  return !(r.x() - r.w() > x_ + w_ || r.x() + r.w() < x_ - w_ ||
           r.y() - r.h() > y_ + h_ || r.y() + r.h() < y_ - h_);
}

double Rectangle::x() const noexcept { return x_; }
double Rectangle::y() const noexcept { return y_; }
double Rectangle::w() const noexcept { return w_; }
double Rectangle::h() const noexcept { return h_; }

#include "QuadTree.h"
#include "Point.h"
#include <iostream>

std::ostream &operator<<(std::ostream &os, const QuadTree &t) {
  os << "Tree(x: " << t.x() << ", y: " << t.y() << "; w: " << t.w()
     << ", h: " << t.h() << ", points: " << t.points.size()
     << " has subsections: " << (t.top_left != nullptr ? "yes" : "no");
  return os;
}

QuadTree::QuadTree(double x, double y, double w, double h, std::size_t capacity)
    : x_(x), y_(y), w_(w), h_(h), _capacity(capacity) {}

QuadTree::~QuadTree() {
  if (hasChildren()) {
    delete top_left;
    delete top_right;
    delete bottom_left;
    delete bottom_right;
  }
}

std::size_t QuadTree::capacity() const noexcept { return _capacity; }
double QuadTree::x() const noexcept { return x_; }
double QuadTree::y() const noexcept { return y_; }
double QuadTree::w() const noexcept { return w_; }
double QuadTree::h() const noexcept { return h_; }
bool QuadTree::hasChildren() const { return top_left != nullptr; }

bool QuadTree::intersects(Point const &center, double width, double height) {
  return !(center.x - width > x_ + w_ || center.x + width < x_ - w_ ||
           center.y - height > y_ + h_ || center.y + height < y_ - h_);
}

std::vector<Point> QuadTree::query(Point const &center, double width,
                                   double height) {
  std::vector<Point> found{};
  if (!intersects(center, width, height)) {
    return found;
  } else {
    for (auto &p : points) {
      found.push_back(p);
    }
    if (hasChildren()) {
      auto r1 = top_left->query(center, width, height);
      auto r2 = top_right->query(center, width, height);
      auto r3 = bottom_left->query(center, width, height);
      auto r4 = bottom_right->query(center, width, height);

      for (auto &p : r1) {
        found.push_back(p);
      }
      for (auto &p : r2) {
        found.push_back(p);
      }
      for (auto &p : r3) {
        found.push_back(p);
      }
      for (auto &p : r4) {
        found.push_back(p);
      }
    }
    return found;
  }
}

void QuadTree::insert(Point p) {
  if (QuadTree::points.size() == capacity()) {
    if (!hasChildren()) {
      split();
    }
    if (top_left->contains(p)) {
      top_left->insert(p);
    } else if (top_right->contains(p)) {
      top_right->insert(p);
    } else if (bottom_left->contains(p)) {
      bottom_left->insert(p);
    } else if (bottom_right->contains(p)) {
      bottom_right->insert(p);
    } else {
      std::cout << p << " " << *this << std::endl;
      std::terminate();
    }
  } else {
    points.push_back(p);
  }
}

bool QuadTree::contains(Point const &p) {
  return (p.x > (x_ - w_)) && (p.x < (x_ + w_)) && (p.y > (y_ - h_)) &&
         (p.y < (y_ + h_));
}

void QuadTree::split() {
  top_left = new QuadTree(x_ - w_ / 2, y_ - h_ / 2, w_ / 2, h_ / 2, _capacity);
  top_right = new QuadTree(x_ + w_ / 2, y_ - h_ / 2, w_ / 2, h_ / 2, _capacity);
  bottom_left =
      new QuadTree(x_ - w_ / 2, y_ + h_ / 2, w_ / 2, h_ / 2, _capacity);
  bottom_right =
      new QuadTree(x_ + w_ / 2, y_ + h_ / 2, w_ / 2, h_ / 2, _capacity);
}

void QuadTree::printTree(int depth) const {
  for (int i = 0; i < depth; i++) {
    std::cout << "  ";
  }
  std::cout << *this;
  if (!hasChildren()) {
    std::cout << "  " << points << std::endl;
  } else {
    std::cout << std::endl;
    for (int i = 0; i < depth + 1; i++) {
      std::cout << "  ";
    }
    std::cout << "Points: " << points << std::endl;
    top_left->printTree(depth + 1);
    top_right->printTree(depth + 1);
    bottom_left->printTree(depth + 1);
    bottom_right->printTree(depth + 1);
  }
}

void QuadTree::printTreeShort(int depth) const {
  for (int i = 0; i < depth; i++) {
    std::cout << "  ";
  }
  std::cout << "|" << points << "" << std::endl;
  if (hasChildren()) {
    top_left->printTreeShort(depth + 1);
    top_right->printTreeShort(depth + 1);
    bottom_left->printTreeShort(depth + 1);
    bottom_right->printTreeShort(depth + 1);
  }
}

void QuadTree::printTreeShort() const { printTreeShort(0); }

void QuadTree::printTree() const { printTree(0); }

void QuadTree::clear() {
  points = std::vector<Point>{};
  if (hasChildren()) {
    delete top_left;
    delete top_right;
    delete bottom_left;
    delete bottom_right;

    top_left = nullptr;
    top_right = nullptr;
    bottom_left = nullptr;
    bottom_right = nullptr;
  }
}

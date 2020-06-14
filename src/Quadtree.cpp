#include "QuadTree.h"
#include "Point.h"
#include <iostream>

// ostream operators for printing

template <typename T>
static std::ostream &operator<<(std::ostream &os, const std::vector<T> &v) {
  os << "[";
  for (auto elt : v) {
    os << elt << ", ";
  }
  os << "nil]";
  return os;
}

std::ostream &operator<<(std::ostream &os, const QuadTree &t) {
  os << "Tree(x: " << t.x() << ", y: " << t.y() << "; w: " << t.w()
     << ", h: " << t.h() << ", points: " << t.points.size()
     << " has subsections: " << (t.hasChildren() ? "yes" : "no");
  return os;
}

// constructors

QuadTree::QuadTree(Rectangle r, std::size_t capacity)
    : boundary_(r), capacity_(capacity) {}

QuadTree::QuadTree(double x, double y, double w, double h, std::size_t capacity)
    : boundary_({x, y, w, h}), capacity_(capacity) {}

// public functions

bool QuadTree::contains(Point const &p) const noexcept {
  return boundary_.contains(p);
}

bool QuadTree::intersects(Rectangle const &r) const noexcept {
  return boundary_.intersects(r);
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

std::vector<Point> QuadTree::query(Rectangle const &r) {
  std::vector<Point> found{};
  if (!intersects(r)) {
    return found;
  } else {
    for (auto &p : points) {
      if (r.contains(p)) {
        found.push_back(p);
      }
    }
    if (hasChildren()) {
      auto const &r1 = top_left->query(r);
      auto const &r2 = top_right->query(r);
      auto const &r3 = bottom_left->query(r);
      auto const &r4 = bottom_right->query(r);

      for (auto const &p : r1) {
        found.push_back(p);
      }
      for (auto const &p : r2) {
        found.push_back(p);
      }
      for (auto const &p : r3) {
        found.push_back(p);
      }
      for (auto const &p : r4) {
        found.push_back(p);
      }
    }
    return found;
  }
}

void QuadTree::clear() {
  points = std::vector<Point>{};
  isSplit = false;
  if (hasChildren()) {
    top_left.reset();
    top_right.reset();
    bottom_left.reset();
    bottom_right.reset();
  }
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

// accessors

std::size_t QuadTree::capacity() const noexcept { return capacity_; }
bool QuadTree::hasChildren() const noexcept { return isSplit; }
Rectangle const &QuadTree::boundary() const noexcept { return boundary_; }
double QuadTree::x() const noexcept { return boundary_.x(); }
double QuadTree::y() const noexcept { return boundary_.y(); }
double QuadTree::w() const noexcept { return boundary_.w(); }
double QuadTree::h() const noexcept { return boundary_.h(); }

// private functions

void QuadTree::split() {
  isSplit = true;
  top_left = std::unique_ptr<QuadTree>(
      new QuadTree(x() - w() / 2, y() - h() / 2, w() / 2, h() / 2, capacity_));
  top_right = std::unique_ptr<QuadTree>(
      new QuadTree(x() + w() / 2, y() - h() / 2, w() / 2, h() / 2, capacity_));
  bottom_left = std::unique_ptr<QuadTree>(
      new QuadTree(x() - w() / 2, y() + h() / 2, w() / 2, h() / 2, capacity_));
  bottom_right = std::unique_ptr<QuadTree>(
      new QuadTree(x() + w() / 2, y() + h() / 2, w() / 2, h() / 2, capacity_));
}

void QuadTree::printTreeShort() const { printTreeShort(0); }

void QuadTree::printTree() const { printTree(0); }

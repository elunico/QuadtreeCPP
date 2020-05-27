#ifndef QUADTREE_H
#define QUADTREE_H

#include "Point.h"
#include <cstdlib>
#include <vector>

class QuadTree {
private:
  double x_, y_, w_, h_;
  std::size_t _capacity;
  std::vector<Point> points{};
  QuadTree *top_left = nullptr;
  QuadTree *top_right = nullptr;
  QuadTree *bottom_left = nullptr;
  QuadTree *bottom_right = nullptr;

  void split();
  void printTree(int depth) const;
  void printTreeShort(int depth) const;

public:
  QuadTree(double x, double y, double w, double h, std::size_t capacity);
  virtual ~QuadTree();

  void insert(Point p);

  bool contains(Point const &p);

  bool intersects(Point const &center, double width, double height);

  bool hasChildren() const;

  void clear();

  std::vector<Point> query(Point const &center, double width, double height);

  std::size_t capacity() const noexcept;

  void printTree() const;
  void printTreeShort() const;

  double x() const noexcept;
  double y() const noexcept;
  double w() const noexcept;
  double h() const noexcept;

  friend std::ostream &operator<<(std::ostream &os, const QuadTree &t);
};

template <typename T>
std::ostream &operator<<(std::ostream &os, const std::vector<T> &v) {
  os << "[";
  for (auto elt : v) {
    os << elt << ", ";
  }
  os << "nil]";
  return os;
}

#endif

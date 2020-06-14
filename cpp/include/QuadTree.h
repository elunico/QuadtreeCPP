#ifndef QUADTREE_H
#define QUADTREE_H

#include "Point.h"
#include "Rectangle.h"
#include <cstdlib>
#include <memory>
#include <vector>

class QuadTree {
private:
  Rectangle boundary_;
  std::size_t capacity_;
  std::vector<Point> points{};
  std::unique_ptr<QuadTree> top_left;
  std::unique_ptr<QuadTree> top_right;
  std::unique_ptr<QuadTree> bottom_left;
  std::unique_ptr<QuadTree> bottom_right;
  bool isSplit = false;

  void split();
  void printTree(int depth) const;
  void printTreeShort(int depth) const;

public:
  QuadTree(Rectangle r, std::size_t capacity);
  QuadTree(double x, double y, double w, double h, std::size_t capacity);

  bool contains(Point const &p) const noexcept;

  bool intersects(Rectangle const &r) const noexcept;

  void insert(Point p);

  std::vector<Point> query(Rectangle const &r);

  void clear();

  void printTree() const;

  void printTreeShort() const;

  std::size_t capacity() const noexcept;
  bool hasChildren() const noexcept;
  Rectangle const &boundary() const noexcept;
  double x() const noexcept;
  double y() const noexcept;
  double w() const noexcept;
  double h() const noexcept;

  friend std::ostream &operator<<(std::ostream &os, const QuadTree &t);
};

#endif

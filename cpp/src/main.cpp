#include "QuadTree.h"
#include <cstdlib>
#include <iostream>

const double width = 200.0;
const double height = 200.0;

const int POINTS = 20000;

double random(double bound) { return bound * (rand() / ((double)RAND_MAX)); }

int main(int argc, char const *argv[]) {
  srand(time(NULL));
  QuadTree t{width / 2, height / 2, width / 2, height / 2, 4};
  std::vector<Point> points{POINTS};

  for (int i = 0; i < 5; i++) {

    for (int i = 0; i < POINTS; i++) {
      Point p{random(width), random(height)};
      t.insert(p);
      points.push_back(p);
    }

    long count = 0;
    for (auto &p : points) {
      auto others = t.query({p.x, p.y, 10, 10});
      for (auto &other : others) {
        // for (auto &other : points) {
        if (&p != &other) {
          if (p.distance_to(other) < 3.0) {
            count++;
          }
        }
      }
    }

    std::cout << "Round " << i << ": There are " << count
              << " overlapping points" << std::endl;
    t.clear();
    points.clear();
  }
  return 0;
}

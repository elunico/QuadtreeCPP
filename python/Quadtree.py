from Rectangle import Rectangle
from Point import Point
import random


class Quadtree:
    def __init__(self, x, y, w, h, capacity):
        self.bounds = Rectangle(Point(x, y), w, h)
        self.points = []
        self.tl = None
        self.tr = None
        self.bl = None
        self.br = None
        self.split = False
        self.capacity = capacity

    def contains(self, other):
        return self.bounds.contains(other)

    def intersects(self, other):
        return self.bounds.intersects(other)

    def has_children(self):
        return self.split

    def insert(self, p):
        if len(self.points) == self.capacity:
            if not self.has_children():
                self.divide()
            if self.tl.contains(p):
                self.tl.insert(p)
            elif self.tr.contains(p):
                self.tr.insert(p)
            elif self.bl.contains(p):
                self.bl.insert(p)
            elif self.br.contains(p):
                self.br.insert(p)
            else:
                raise ValueError("No subtree found for point {}".format(p))
        else:
            self.points.append(p)

    def query(self, r):
        found = []
        if not self.intersects(r):
            return found
        else:
            found.extend([i for i in self.points if r.contains(i)])
            if self.has_children():
                found.extend(self.tl.query(r))
                found.extend(self.tr.query(r))
                found.extend(self.bl.query(r))
                found.extend(self.br.query(r))
            return found

    def divide(self):
        self.tl = Quadtree(
            self.bounds.x() - self.bounds.width / 2.0,
            self.bounds.y() - self.bounds.height / 2.0,
            self.bounds.width / 2.0,
            self.bounds.height / 2.0,
            self.capacity,
        )
        self.tr = Quadtree(
            self.bounds.x() + self.bounds.width / 2.0,
            self.bounds.y() - self.bounds.height / 2.0,
            self.bounds.width / 2.0,
            self.bounds.height / 2.0,
            self.capacity,
        )
        self.bl = Quadtree(
            self.bounds.x() - self.bounds.width / 2.0,
            self.bounds.y() + self.bounds.height / 2.0,
            self.bounds.width / 2.0,
            self.bounds.height / 2.0,
            self.capacity,
        )
        self.br = Quadtree(
            self.bounds.x() + self.bounds.width / 2.0,
            self.bounds.y() + self.bounds.height / 2.0,
            self.bounds.width / 2.0,
            self.bounds.height / 2.0,
            self.capacity,
        )
        self.split = True

    def clear(self):
        self.points = []
        self.tl = None
        self.tr = None
        self.bl = None
        self.br = None
        self.split = False


def main():
    TOTAL_POINTS = 20000
    w = 200.0
    h = 200.0
    qt = Quadtree(w/2.0, h/2.0, w/2.0, h/2.0, 4)
    points = []

    for i in range(5):
        for _ in range(TOTAL_POINTS):
            x = random.random() * 200.0
            y = random.random() * 200.0
            p = Point(x, y)
            qt.insert(p)
            points.append(p)

        count = 0
        for point in points:
            r = Rectangle(Point(point.x, point.y), 10.0, 10.0)
            for other in qt.query(r):
                if point != other and point.dist_to(other) < 3.0:
                    count += 1
        print("Round {}: Found {} overlapping points".format(i, count))
        qt.clear()
        points = []


if __name__ == "__main__":
    exit(main())

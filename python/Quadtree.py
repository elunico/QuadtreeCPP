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
            for p in self.points:
                if r.contains(p):
                    found.append(p)
            if self.has_children():
                r1 = self.tl.query(r)
                r2 = self.tr.query(r)
                r3 = self.bl.query(r)
                r4 = self.br.query(r)

                for p in r1:
                    found.append(p)
                for p in r2:
                    found.append(p)
                for p in r3:
                    found.append(p)
                for p in r4:
                    found.append(p)
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
    # about 10 times slower than C++ and Rust so 1/10 the points
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
                if point != other and point.distanceto(other) < 3.0:
                    count += 1
        print("Round {}: Found {} overlapping points".format(i, count))
        qt.clear()
        points = []


if __name__ == "__main__":
    exit(main())
import math


class Point:
    def __init__(self, x, y):
        self.x = x
        self.y = y

    def __eq__(self, other):
        return self.x == other.x and self.y == other.y

    def __str__(self):
        return '({}, {})'.format(self.x, self.y)

    def __repr__(self):
        return 'Point{}'.format(self.__str__())

    def dist_to(self, other):
        return math.sqrt(math.pow(self.x - other.x, 2) +
                         math.pow(self.y - other.y, 2))

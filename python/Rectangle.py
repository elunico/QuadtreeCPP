class Rectangle:
    def __init__(self, center, width, height):
        self.center = center
        self.width = width
        self.height = height

    def x(self):
        return self.center.x

    def y(self):
        return self.center.y

    def contains(self, other):
        return (other.x > (self.x() - self.width))\
            and (other.x < (self.x() + self.width))\
            and (other.y > (self.y() - self.height))\
            and (other.y < (self.y() + self.height))

    def intersects(self, other):
        return not (other.x() - other.width > self.x() + self.width
                    or other.x() + other.width < self.x() - self.width
                    or other.y() - other.height > self.y() + self.height
                    or other.y() + other.height < self.y() - self.height)

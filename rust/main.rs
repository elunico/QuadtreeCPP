#[derive(Debug, Copy, Clone, PartialEq)]
struct Point {
  x: f64,
  y: f64,
}

impl Point {
  fn distance_to(&self, other: &Point) -> f64 {
    return ((self.x - other.x).powf(2.0) + (self.y - other.y).powf(2.0)).sqrt();
  }
}

#[derive(Debug, Copy, Clone, PartialEq)]
struct Rectangle {
  center: Point,
  width: f64,
  height: f64,
}

impl Rectangle {
  fn x(&self) -> f64 {
    self.center.x
  }

  fn y(&self) -> f64 {
    self.center.y
  }

  fn contains(&self, other: &Point) -> bool {
    (other.x > (self.x() - self.width))
      && (other.x < (self.x() + self.width))
      && (other.y > (self.y() - self.height))
      && (other.y < (self.y() + self.height))
  }

  fn intersects(&self, other: &Rectangle) -> bool {
    !(other.x() - other.width > self.x() + self.width
      || other.x() + other.width < self.x() - self.width
      || other.y() - other.height > self.y() + self.height
      || other.y() + other.height < self.y() - self.height)
  }
}

#[derive(Debug)]
struct Quadtree {
  bounds: Rectangle,
  points: Vec<Point>,
  top_left: Option<Box<Quadtree>>,
  top_right: Option<Box<Quadtree>>,
  bottom_left: Option<Box<Quadtree>>,
  bottom_right: Option<Box<Quadtree>>,
  split: bool,
  capacity: usize,
}

impl Quadtree {
  fn contains(&self, other: &Point) -> bool {
    self.bounds.contains(other)
  }

  fn intersects(&self, other: &Rectangle) -> bool {
    self.bounds.intersects(other)
  }

  fn has_children(&self) -> bool {
    self.split
  }

  fn insert(&mut self, p: Point) {
    if self.points.len() == self.capacity {
      if !self.has_children() {
        self.divide();
      }
      if self.top_left.as_ref().unwrap().contains(&p) {
        self.top_left.as_mut().unwrap().insert(p);
      } else if self.top_right.as_ref().unwrap().contains(&p) {
        self.top_right.as_mut().unwrap().insert(p);
      } else if self.bottom_left.as_ref().unwrap().contains(&p) {
        self.bottom_left.as_mut().unwrap().insert(p);
      } else if self.bottom_right.as_ref().unwrap().contains(&p) {
        self.bottom_right.as_mut().unwrap().insert(p);
      } else {
        panic!("Insert could not find a subtree to insert into");
      }
    } else {
      self.points.push(p);
    }
  }

  fn query(&self, r: &Rectangle) -> Vec<Point> {
    let mut found = Vec::new();
    if !self.intersects(r) {
      return found;
    } else {
      for p in &self.points {
        if r.contains(p) {
          found.push(*p);
        }
      }
      if self.has_children() {
        let r1 = self.top_left.as_ref().unwrap().query(r);
        let r2 = self.top_right.as_ref().unwrap().query(r);
        let r3 = self.bottom_left.as_ref().unwrap().query(r);
        let r4 = self.bottom_right.as_ref().unwrap().query(r);

        for p in r1 {
          found.push(p);
        }
        for p in r2 {
          found.push(p);
        }
        for p in r3 {
          found.push(p);
        }
        for p in r4 {
          found.push(p);
        }
      }
      return found;
    }
  }

  fn divide(&mut self) {
    self.top_left = Some(Box::new(Quadtree::new(
      self.bounds.x() - self.bounds.width / 2.0,
      self.bounds.y() - self.bounds.height / 2.0,
      self.bounds.width / 2.0,
      self.bounds.height / 2.0,
      self.capacity,
    )));
    self.top_right = Some(Box::new(Quadtree::new(
      self.bounds.x() + self.bounds.width / 2.0,
      self.bounds.y() - self.bounds.height / 2.0,
      self.bounds.width / 2.0,
      self.bounds.height / 2.0,
      self.capacity,
    )));
    self.bottom_left = Some(Box::new(Quadtree::new(
      self.bounds.x() - self.bounds.width / 2.0,
      self.bounds.y() + self.bounds.height / 2.0,
      self.bounds.width / 2.0,
      self.bounds.height / 2.0,
      self.capacity,
    )));
    self.bottom_right = Some(Box::new(Quadtree::new(
      self.bounds.x() + self.bounds.width / 2.0,
      self.bounds.y() + self.bounds.height / 2.0,
      self.bounds.width / 2.0,
      self.bounds.height / 2.0,
      self.capacity,
    )));
    self.split = true;
  }

  fn clear(&mut self) {
    self.points.clear();
    if self.top_left.is_some() {
      drop(self.top_left.as_ref());
    }
    if self.top_right.is_some() {
      drop(self.top_right.as_ref());
    }
    if self.bottom_left.is_some() {
      drop(self.bottom_left.as_ref());
    }
    if self.bottom_right.is_some() {
      drop(self.bottom_right.as_ref());
    }
    self.top_left = None;
    self.top_right = None;
    self.bottom_left = None;
    self.bottom_right = None;
    self.split = false;
  }

  fn new(x: f64, y: f64, w: f64, h: f64, capacity: usize) -> Quadtree {
    let center = Point { x, y };
    let bounds = Rectangle {
      center,
      width: w,
      height: h,
    };
    Quadtree {
      bounds: bounds,
      points: Vec::new(),
      top_left: None,
      top_right: None,
      bottom_left: None,
      bottom_right: None,
      split: false,
      capacity: capacity,
    }
  }
}

use rand::prelude::random;
fn main() {
  let total_points = 20000;
  let w = 200.0;
  let h = 200.0;
  let mut qt = Quadtree::new(w / 2.0, h / 2.0, w / 2.0, h / 2.0, 4);
  let mut points = Vec::<Point>::new();

  for i in 0..5 {
    for _ in 0..total_points {
      let x = random::<f64>() * w;
      let y = random::<f64>() * h;
      let p = Point { x, y };
      qt.insert(p);
      points.push(p)
    }

    let mut count = 0;
    for point in &points {
      let r = Rectangle {
        center: Point {
          x: point.x,
          y: point.y,
        },
        width: 10.0,
        height: 10.0,
      };
      // for other in &points {
      for other in &qt.query(&r) {
        if *point != *other && point.distance_to(other) < 3.0 {
          count += 1;
        }
      }
    }
    println!("Round {}: Found {} overlapping points", i, count);
    qt.clear();
    points.clear();
  }
}

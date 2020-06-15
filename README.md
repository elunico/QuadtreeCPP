# Quadtrees
Some Quadtree implementations inspired by a [Coding Train](https://www.youtube.com/channel/UCvjgXvBlbQiydffZU7m1_aw) Coding Challenge

I watched Dan Shiffman (@shiffman) on the Coding Train (@codingtrain) implement a QuadTree in JavaScript and thought I would have a try in C++. The
algorithm seemed straightforward and I thought it would be a fun exercise since I rarely get to do C++. Then when I was
trying to learn some Rust, I also ported it to Rust.

I am not affiliated with the Coding Train, I just like the videos

###### Disclaimer: I have fairly strong knowedge of Python and C++ but Swift and especially Rust are not languages that I have a lot of experience writing, and so the implementations may not be that efficient

### Ranking So Far

The test being run is creating 20000 points within a 200 by 200 space and adding them all to a list (vector, slice, array, etc.) and inserting them into the quadtree. Then the program iterates through every point, and asks the quadtree for the points near to that point. It then checks every point that the quadtree returns (a small fraction of the total points) and see if any "overlap." Points are arbitrarily considered to have a size of 1.5 so that if two points are within a distance of 3 of each other they overlap. This program is not concerned with double or over counting

| Language                  | Relative Speed |
| ------------------------- | -------------- |
| C++                       | 1.0            |
| Rust                      | 1.5            |
| Swift                     | 2.0            |
| Go* (w/ big Goroutines)   | 2.5            |
| Go*                       | 15.0           |
| Ruby                      | 19.0           |
| Go* (w/ small Goroutines) | 24.0           |
| Python3                   | 41.0           |

&nbsp;* *I wrote the Go implementation normally, as I did the other ones. It was very slow, at 15 times slower than C++. Then I wrote the `func (qt *Quadtree) query(r *Rectange) []Point` function with goroutines where each recursive call happened in its own goroutine. This is what I refer to as "small Goroutines" because each
goroutine was very small consisting of only a couple of a checks and a `for`-loop. This was even worse, and I suspect this is because query is called for every point in the list meaning a channel was created and many goroutines spun up for each of the 20000 points being iterated through. However, then I tried splitting the
points into batches. When checking the points, I do not care about double counting overlaps, so I split the
points into groups so that there are 10 groups. I then had 10 goroutines run and check all the points in the
group for overlap using the quadtree. This resulted in a big speed up.*

Speed is done in relative multiples. So, for example, this means that python3 was 10 times slower than C++ and 2 times slower than Ruby
or that Swift was 2.8 times faster than Ruby.

Something important to note is that the width and height of the area being tested is 200.0 and the
"size" of the points is 1.5. Points are added to a list (vector, slice, etc.) and the quadtree. The
program then iterates over every point in the list and asks the quadtree for the points near it.
It counts overlapping points by checking all the points returned by the quadtree to see if any are
within a distance of 3 to the point it is examining. All tests are run with 20000 points. This is
critical because the quadtree will return more points when there are more points in the area. This
is because the area being queries is constant so it will have to return more points if 20000 are
randomly distributed in a 200x200 space than if 2000 were. What this means is that, if you cut the
number of points by 10 from 20000 to 2000, python is as fast as C++, but this is misleading because
C++ is receiving many more points from the quadtree. As such, when using 20000 points in both
implementations python is not 10 times slower but 41 times slower.

Actual run time in time units are not provided due to their variability and platform specificity.

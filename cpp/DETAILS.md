# Implementation Details

When a quadtree reaches capacity, it is split into 4 subsections. All 4
subsections are allocation and initialized as soon as the tree is split,
even if they are never used. This results in many, many allocations
if the points are dense, since trees continue having to split even
as less and less points can fill a smaller and smaller area.

Consider the setup as follows.
A std::vector of points is stack-allocated using the capacity given based
on the number of points. A quadtree is also stack-allocation with no
preallocation since there is no means of preallocation for the quadtree.
A for-loop creates the given number of points between some 'width' and 'height'
which are just arbitrary numbers that serve as the bounds of the point objects.
The loop `push_back`s into the vector and `insert`s into the quadtree.


 - When the number of points is `16000` if the width and height are both `20000`, this
 results in a relatively sparse distribution of points and according to `valgrind`, `1,155,933 allocs` allocating `146,111,776 bytes`.
 - However, when the number of points is `16000` but the width and height are both `200`,
 this results in a highly dense concentration of points. These more densly packed points
 require more splitting of the tree which not only requires more allocation but can do so
 inefficiently if points never land in a subtree (say there are 6 points and they all fit in the
 `top_left` of a tree) as this always requires allocating all 4 subtrees. Valgrind reports
 in this case `6,495,579 allocs` and `1,487,149,296 bytes allocated` despite the same number of points
 being used.

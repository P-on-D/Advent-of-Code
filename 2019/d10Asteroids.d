import std.array, std.algorithm, std.typecons;

/**
 * [Pt] represents an point in 2D space, with a specific ordering
 */
struct Pt {
  int x, y;

  /// [Pt]s with lower `x`s order first, then lower `y`s
  int opCmp(ref const Pt s) const {
    return x == s.x ? y - s.y : x - s.x;
  }
}

/**
 * [NMV] represents the Normalised Manhattan Vector between two [Pt]s
 *
 * This structure was inspired by the diagram on the puzzle showing which
 * asteroids were responsible for occluding which others. From `Pt(0,0)`
 * the asteroid at `Pt(3,3)` has `NVM(1,1,3,1,1,6)` and the asteroid at
 * `Pt(4,4)` has `NMV(1,1,4,1,1,8)`. They are on the same Manhattan vector
 * (`xdist`, `ydist`, `xdir` and `ydir` are equal) differing only by `scale`
 * so the former occludes the latter and all others with the same vector.
 */
struct NMV {
  import std.math, std.numeric;

  Pt p; /// I suspect this is here as a convenience

  int
    xdist, /// normalised difference between x co-ords
    ydist, /// normalised difference between y co-ords
    scale, /// i.e. xdist * scale = absolute difference between x co-ords
    xdir,  /// direction of x (-1, 0, 1)
    ydir,  /// direction of y (-1, 0, 1)
    dist;  /// Manhattan distance

  this(Pt u, Pt v)
  {
    p = v; /// yeah, this is odd
    if (u == v) return; /// this is also odd

    xdir = sgn(v.x - u.x);
    xdist = abs(v.x - u.x);

    ydir = sgn(v.y - u.y);
    ydist = abs(v.y - u.y);

    // if both components divide by the same amount, the vector can be normalised
    scale = gcd(xdist, ydist);

    dist = xdist + ydist;

    // if the vector cannot be normalised, scale = 1
    xdist /= scale;
    ydist /= scale;
  }
}

/**
 * Convert the input (a grid of characters with '#' indicating an asteroid) into
 * a list of asteroid co-ordinates.
 */
auto toAsteroids(string[] input) {
  Pt[] asteroids;

  foreach(int y, line; input) {
    foreach(int x, cell; line) {
      if (cell == '#') asteroids ~= Pt(x, y);
    }
  }

  return asteroids;
}

/**
 * Determine the asteroids visible from a given point
 *
 * [pt] is considered to be in the asteroid field and will be the first result.
 * Compute the NMV for each asteroid from [pt], group by NMV in scale order and
 * return the first of each group.
 */
auto visibleFrom(R)(R asteroids, Pt pt) {
  return asteroids
    .map!(a => NMV(pt, a))
    .array
    .multiSort!("a.xdist < b.xdist", "a.ydist < b.ydist", "a.xdir < b.xdir", "a.ydir < b.ydir", "a.scale < b.scale")
    .uniq!("a.xdist == b.xdist && a.ydist == b.ydist && a.xdir == b.xdir && a.ydir == b.ydir");
}

/// Return the number of asteroids seen from [pt]
auto seenFrom(Pt pt, Pt[] asteroids) {
  return cast(int)asteroids.visibleFrom(pt).count - 1;
}

/// Graph the number of asteroids seen from each point on the input grid
auto visibility(string[] input) {
  auto asteroids = toAsteroids(input);
  auto vis = input.map!(a => new int[](a.length)).array;

  foreach(pt; asteroids) {
    vis[pt.y][pt.x] = seenFrom(pt, asteroids);
  }

  return vis;
}

/// Answer puzzle part 1 by returning the asteroid that sees the most
auto bestVisibility(Pt[] asteroids) {
  return asteroids
    .map!(pt => tuple(pt, seenFrom(pt, asteroids)))
    .maxElement!"a[1]";
}

/**
 * Answer puzzle part 2 by simulating the rotation of the laser from up,
 * through all the visible asteroids in each of 4 quadrants, sorted by
 * their angle, removing them in that order, repeating until none remain.
 */
auto vapourisationOrder(Pt[] asteroids, Pt base) {
  import std.math, std.range;

  /// Compute the normalised angle between the base and a point, depending on if
  /// the adjacent is on the X or Y
  auto adjX = (NMV a) => atan(cast(float)(a.p.y - base.y) / (a.p.x - base.x));
  auto adjY = (NMV a) => -atan(cast(float)(a.p.x - base.x) / (a.p.y - base.y));

  /// The laser rotates through four quadrants
  auto quadrants = [
    (NMV v) => v.p.y < base.y && v.p.x >= base.x /// up and to the right
  , v => v.p.x > base.x && v.p.y >= base.y       /// right and to down
  , v => v.p.y > base.y && v.p.x <= base.x       /// down and to the left
  , v => v.p.x < base.x && v.p.y <= base.y       /// left and to up
  ]
  .zip(
    [adjY, adjX, adjY, adjX] /// Which angle function to apply to which quadrant
  );

  auto remaining = asteroids.sort.filter!(a => a != base).array;
  Pt[] candidates;

  do {
    auto visible = remaining.visibleFrom(base);

    /// `fns[0]` is the quadrant filter, `fns[1]` is the angle
    auto newCandidates = quadrants
      .map!(fns =>
        visible.filter!(v => fns[0](v))
          .map!(v => tuple(v.p, fns[1](v)))
          .array.sort!"a[1] < b[1]"
      )
      .join
      .map!"a[0]"
      .array;
    candidates ~= newCandidates;

    if (candidates.length < asteroids.length) {
      remaining = remaining.setDifference(newCandidates.sort).array;
    }
  } while(remaining.length);

  return candidates;
}

unittest {
  void test(T, U)(T received, U expected) {
    import std.format;
    assert(received == expected, format!"Expected %s received %s"(expected, received));
  }

  test(
    visibility([
      ".#..#"
    , "....."
    , "#####"
    , "....#"
    , "...##"
    ]),
    [
      [0,7,0,0,7]
    , [0,0,0,0,0]
    , [6,7,7,7,5]
    , [0,0,0,0,7]
    , [0,0,0,8,7]
    ]
  );

  test(
    bestVisibility(toAsteroids([
      "......#.#."
    , "#..#.#...."
    , "..#######."
    , ".#.#.###.."
    , ".#..#....."
    , "..#....#.#"
    , "#..#....#."
    , ".##.#..###"
    , "##...#..#."
    , ".#....####"
    ])),
    tuple(Pt(5, 8), 33)
  );

  test(
    bestVisibility(toAsteroids([
      "#.#...#.#."
    , ".###....#."
    , ".#....#..."
    , "##.#.#.#.#"
    , "....#.#.#."
    , ".##..###.#"
    , "..#...##.."
    , "..##....##"
    , "......#..."
    , ".####.###."
    ])),
    tuple(Pt(1, 2), 35)
  );

  test(
    bestVisibility(toAsteroids([
      ".#..#..###"
    , "####.###.#"
    , "....###.#."
    , "..###.##.#"
    , "##.##.#.#."
    , "....###..#"
    , "..#.#..#.#"
    , "#..#.#.###"
    , ".##...##.#"
    , ".....#.#.."
    ])),
    tuple(Pt(6, 3), 41)
  );

  auto largeExample = toAsteroids([
    ".#..##.###...#######"
  , "##.############..##."
  , ".#.######.########.#"
  , ".###.#######.####.#."
  , "#####.##.#.##.###.##"
  , "..#####..#.#########"
  , "####################"
  , "#.####....###.#.#.##"
  , "##.#################"
  , "#####.##.###..####.."
  , "..######..##.#######"
  , "####.##.####...##..#"
  , ".#####..#.######.###"
  , "##...#.##########..."
  , "#.##########.#######"
  , ".####.#.###.###.#.##"
  , "....##.##.###..#####"
  , ".#.#.###########.###"
  , "#.#.#.#####.####.###"
  , "###.##.####.##.#..##"
  ]);

  test(
    bestVisibility(largeExample.dup),
    tuple(Pt(11, 13), 210)
  );

  auto astsToVape = toAsteroids([
    ".#....#####...#.."
  , "##...##.#####..##"
  , "##...#...#.#####."
  , "..#.....#...###.."
  , "..#.#.....#....##"
  ]);

  test(
    vapourisationOrder(astsToVape, Pt(8, 3))[0..9]
  , [
      Pt(8,1), Pt(9,0), Pt(9,1), Pt(10,0), Pt(9,2), Pt(11,1), Pt(12,1), Pt(11,2), Pt(15,1)
    ]
  );

  test(
    vapourisationOrder(astsToVape, Pt(8, 3))[9..18]
  , [
      Pt(12,2), Pt(13,2), Pt(14,2), Pt(15,2), Pt(12,3), Pt(16,4), Pt(15,4), Pt(10,4), Pt(4,4)
    ]
  );

  test(
    vapourisationOrder(astsToVape, Pt(8, 3))[18..27]
  , [
      Pt(2,4), Pt(2,3), Pt(0,2), Pt(1,2), Pt(0,1), Pt(1,1), Pt(5,2), Pt(1,0), Pt(5,1)
    ]
  );

  test(
    vapourisationOrder(astsToVape, Pt(8, 3))[27..$]
  , [
      Pt(6,1), Pt(6,0), Pt(7,0), Pt(8,0), Pt(10,1), Pt(14,0), Pt(16,1), Pt(13,3), Pt(14,3)
    ]
  );

  auto largeVape = vapourisationOrder(largeExample, Pt(11,13));
  assert(largeVape[0] == Pt(11,12));
  assert(largeVape[1] == Pt(12,1));
  assert(largeVape[2] == Pt(12,2));
  assert(largeVape[9] == Pt(12,8));
  assert(largeVape[19] == Pt(16,0));
  assert(largeVape[49] == Pt(16,9));
  assert(largeVape[99] == Pt(10,16));
  assert(largeVape[198] == Pt(9,6));
  assert(largeVape[199] == Pt(8,2));
  assert(largeVape[200] == Pt(10,9));
  assert(largeVape[$-1..$] == [Pt(11,1)]);
} version (unittest) {} else {

void main() {
  import std.array, std.stdio;

  auto asteroids = stdin.byLineCopy.array.toAsteroids;

  auto base = asteroids.dup.bestVisibility;
  base.writeln;

  auto bettingAsteroid = asteroids.dup.vapourisationOrder(base[0])[199];
  writeln(bettingAsteroid.x * 100 + bettingAsteroid.y);
}

}
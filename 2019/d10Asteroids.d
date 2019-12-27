import std.array, std.algorithm, std.typecons;

struct Pt { int x, y; int opCmp(ref const Pt s) const { return x == s.x ? y - s.y : x - s.x; } }

struct NMV {
  import std.math, std.numeric;

  Pt p;
  int xdist, ydist, scale, xdir, ydir, dist;

  this(Pt u, Pt v) {
    p = v;
    if (u == v) return;

    xdir = sgn(v.x - u.x);
    xdist = abs(v.x - u.x);

    ydir = sgn(v.y - u.y);
    ydist = abs(v.y - u.y);

    scale = gcd(xdist, ydist);

    dist = xdist + ydist;

    xdist /= scale;
    ydist /= scale;
  }
}

auto toAsteroids(string[] input) {
  Pt[] asteroids;

  foreach(int row, line; input) {
    foreach(int col, cell; line) {
      if (cell == '#') asteroids ~= Pt(col, row);
    }
  }

  return asteroids;
}

auto visibleFrom(Pt[] asteroids, Pt pt) {
  return asteroids
    .map!(a => NMV(pt, a))
    .array
    .multiSort!("a.xdist < b.xdist", "a.ydist < b.ydist", "a.xdir < b.xdir", "a.ydir < b.ydir", "a.scale < b.scale")
    .uniq!("a.xdist == b.xdist && a.ydist == b.ydist && a.xdir == b.xdir && a.ydir == b.ydir");
}

auto seenFrom(Pt pt, Pt[] asteroids) {
  return cast(int)asteroids.visibleFrom(pt).count - 1;
}

auto visibility(string[] input) {
  Pt[] asteroids;
  int[][] vis;

  foreach(int row, line; input) {
    foreach(int col, cell; line) {
      if (cell == '#') asteroids ~= Pt(col, row);
    }
    vis ~= new int[line.length];
  }

  foreach(pt; asteroids) {
    vis[pt.y][pt.x] = seenFrom(pt, asteroids);
  }

  return vis;
}

auto bestVisibility(Pt[] asteroids) {
  Tuple!(Pt, int)[] vis;
  foreach(pt; asteroids) {
    vis ~= tuple(pt, seenFrom(pt, asteroids));
  }

  return vis.maxElement!"a[1]";
}

auto vapourisationOrder(Pt[] asteroids, Pt base) {
  import std.math;

  Pt[] remaining = asteroids.filter!(a => a != base).array.sort.array;
  Pt[] candidates;

  do {
    auto visible = remaining.visibleFrom(base);

    candidates ~= visible
      .filter!(a => a.p.x >= base.x && a.p.y < base.y)
      .map!(a => tuple(a.p, atan(cast(float)(a.p.x - base.x) / (a.p.y - base.y))))
      .array
      .sort!"a[1] > b[1]"
      .map!"a[0]"
      .array;

    candidates ~= visible
      .filter!(a => a.p.x > base.x && a.p.y >= base.y)
      .map!(a => tuple(a.p, atan(cast(float)(a.p.y - base.y) / (a.p.x - base.x))))
      .array
      .sort!"a[1] < b[1]"
      .map!"a[0]"
      .array;

    candidates ~= visible
      .filter!(a => a.p.x <= base.x && a.p.y > base.y)
      .map!(a => tuple(a.p, atan(cast(float)(a.p.x - base.x) / (a.p.y - base.y))))
      .array
      .sort!"a[1] > b[1]"
      .map!"a[0]"
      .array;

    candidates ~= visible
      .filter!(a => a.p.x < base.x && a.p.y <= base.y)
      .map!(a => tuple(a.p, atan(cast(float)(a.p.y - base.y) / (base.x - a.p.x))))
      .array
      .sort!"a[1] > b[1]"
      .map!"a[0]"
      .array;

    if (candidates.length < asteroids.length) {
      remaining = remaining.setDifference(candidates.dup.sort).array;
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
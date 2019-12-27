struct Pt { int x, y; }

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

auto seenFrom(Pt pt, Pt[] asteroids) {
  import std.algorithm, std.array;

  auto distance = asteroids
    .map!(a => NMV(pt, a))
    .array
    .multiSort!("a.xdist < b.xdist", "a.ydist < b.ydist", "a.xdir < b.xdir", "a.ydir < b.ydir", "a.scale < b.scale")
    .uniq!("a.xdist == b.xdist && a.ydist == b.ydist && a.xdir == b.xdir && a.ydir == b.ydir")
    .count - 1
  ;

  return cast(int)distance;
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
}

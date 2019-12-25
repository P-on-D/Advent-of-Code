import std.array, std.algorithm;

unittest {
  enum Dir { Down = 'D', Left = 'L', Right = 'R', Up = 'U' }

  struct Leg {
    Dir dir;
    int dist;
  }

  Leg toLeg(string spec) {
    import std.conv;
    return Leg(to!Dir(spec[0]), to!int(spec[1..$]));
  }

  assert(toLeg("R8") == Leg(Dir.Right, 8));
  assert(toLeg("U5") == Leg(Dir.Up, 5));
  assert(toLeg("L5") == Leg(Dir.Left, 5));
  assert(toLeg("D3") == Leg(Dir.Down, 3));
  assert(toLeg("R9999") == Leg(Dir.Right, 9999));

  auto parseWire(string spec) {
    return spec
      .split(',')
      .map!toLeg
      .array;
  }

  assert(parseWire("R8,U5,L5,D3,R9999") == [
    Leg(Dir.Right, 8)
  , Leg(Dir.Up, 5)
  , Leg(Dir.Left, 5)
  , Leg(Dir.Down, 3)
  , Leg(Dir.Right, 9999)
  ]);

  struct Pt { int x, y; }
  struct Line {
    Pt orig, dest;

    this(Pt o, Pt d) {
      orig = o;
      dest = d;
    }

    this(int ox, int oy, int dx, int dy) {
      this(Pt(ox, oy), Pt(dx, dy));
    }
  }

  auto wireToLines(Leg[] legs) {
    Pt here;
    Line[] lines;

    foreach(leg; legs) {
      Pt there = here;

      final switch (leg.dir) {
        case Dir.Down: there.y += leg.dist; break;
        case Dir.Left: there.x -= leg.dist; break;
        case Dir.Right: there.x += leg.dist; break;
        case Dir.Up:    there.y -= leg.dist; break;
      }

      lines ~= Line(here, there);
      here = there;
    }

    return lines;
  }

  assert(wireToLines(parseWire("R8,U5,L5,D3,R9999")) == [
    Line(Pt(0, 0), Pt(8, 0))
  , Line(Pt(8, 0), Pt(8, -5))
  , Line(Pt(8, -5), Pt(3, -5))
  , Line(Pt(3, -5), Pt(3, -2))
  , Line(Pt(3, -2), Pt(10002, -2))
  ]);

  auto lines = [
    "R75,D30,R83,U83,L12,D49,R71,U7,L72"
  , "U62,R66,U55,R34,D71,R55,D58,R83"
  ].map!parseWire.array.map!wireToLines.array;

  assert(lines == [
    [
      Line(Pt(0,0), Pt(75, 0))
    , Line(Pt(75, 0), Pt(75,30))
    , Line(Pt(75,30), Pt(75+83,30))
    , Line(Pt(75+83,30), Pt(75+83,30-83))
    , Line(Pt(75+83,30-83), Pt(75+83-12,30-83))
    , Line(Pt(75+83-12,30-83), Pt(75+83-12,30-83+49))
    , Line(Pt(75+83-12,30-83+49), Pt(75+83-12+71,30-83+49))
    , Line(Pt(75+83-12+71,30-83+49), Pt(75+83-12+71,30-83+49-7))
    , Line(Pt(75+83-12+71,30-83+49-7), Pt(75+83-12+71-72,30-83+49-7))
    ]
  , [
      Line(Pt(0,0), Pt(0, -62))
    , Line(Pt(0, -62), Pt(66, -62))
    , Line(Pt(66, -62), Pt(66, -62-55))
    , Line(Pt(66, -62-55), Pt(66+34, -62-55))
    , Line(Pt(66+34, -62-55), Pt(66+34, -62-55+71))
    , Line(Pt(66+34, -62-55+71), Pt(66+34+55, -62-55+71))
    , Line(Pt(66+34+55, -62-55+71), Pt(66+34+55, -62-55+71+58))
    , Line(Pt(66+34+55, -62-55+71+58), Pt(66+34+55+83, -62-55+71+58))
    ]
  ]);

  bool between(T)(T a, T x, T y) {
    return x < y
      ? x <= a && a <= y
      : y <= a && a <= x;
  }

  assert(between(0, 0, 0));
  assert(between(0, 1, -1));
  assert(between(1, 1, -1));
  assert(between(-1, 1, -1));
  assert(between(0, -1, 1));
  assert(between(1, -1, 1));
  assert(between(-1, -1, 1));

  // Since all wires cross at Pt(0, 0), that makes an unambiguous false.
  // Pretty sure lines could entirely overlay but doubt the input is that evil :)
  // So lines cross at their shared Pt(x, y)
  Pt linesCrossAt(Line l1, Line l2) {
    // parallel lines cannot cross
    if(
      (l1.orig.x == l1.dest.x && l2.orig.x == l2.dest.x)
      ||
      (l1.orig.y == l1.dest.y && l2.orig.y == l2.dest.y)
    )
      return Pt(0, 0);

    // perpendicular lines cross
    if (l1.orig.x != l1.dest.x) {
      // l1 is horizontal, l2 verical
      if (between(l1.orig.y, l2.orig.y, l2.dest.y) && between(l2.orig.x, l1.orig.x, l1.dest.x)) {
        return Pt(l2.orig.x, l1.orig.y);
      }
    } else {
      // l1 is vertical, l2 horizontal
      if (between(l1.orig.x, l2.orig.x, l2.dest.x) && between(l2.orig.y, l1.orig.y, l1.dest.y)) {
        return Pt(l1.orig.x, l2.orig.y);
      }
    }

    return Pt(0, 0);
  }

  assert(linesCrossAt(Line(-1, -1, -1, -3), Line(-2, -2, 1, -2)) == Pt(-1, -2));
  assert(linesCrossAt(Line(-1, -1, -1, 3), Line(-2, -2, 1, -2)) == Pt(0, 0));
  assert(linesCrossAt(Line(-2, -2, 1, -2), Line(-1, -1, -1, -3)) == Pt(-1, -2));
  assert(linesCrossAt(Line(-2, -2, 1, -2), Line(-1, -1, -1, 3)) == Pt(0, 0));
/*
  auto closestCrossover(T)(T input) {
    return input
      .map!parseWire
      .map!toLines
      .findCrossovers
      .closest;
  }

  assert(closestCrossover([
    "R8,U5,L5,D3"
  , "U7,R6,D4,L4"
  ]) == 6);
  assert(closestCrossover([
    "R75,D30,R83,U83,L12,D49,R71,U7,L72"
  , "U62,R66,U55,R34,D71,R55,D58,R83"
  ]) == 159);
  assert(closestCrossover([
    "R98,U47,R26,D63,R33,U87,L62,D20,R33,U53,R51"
  , "U98,R91,D20,R16,D67,R40,U7,R15,U6,R7"
  ]) == 135);
*/}

import std.algorithm;

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

  auto parseWire(T)(T spec) {
    import std.array;

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
/*
  struct Pt { int x, y; }
  struct Line { Pt orig, dest; }

  auto legsToLines(T)(T legs) {
    Pt here;
    Line[] lines = Line(legs.length);

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

  auto toLines(T)(T wires) {
    return wires
      .map!legsToLines;
  }

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

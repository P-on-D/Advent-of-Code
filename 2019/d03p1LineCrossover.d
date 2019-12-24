import std.algorithm;

unittest {
  struct Leg {
    char dir;
    int dist;
  }

  Leg toLeg(T)(T spec) {
    import std.conv;
    return Leg(spec[0], to!int(spec[1..$]));
  }

  auto parseWire(T)(T spec) {
    import std.array;

    return spec
      .split(',')
      .map!toLeg;
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
}

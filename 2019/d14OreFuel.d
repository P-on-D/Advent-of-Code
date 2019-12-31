import std.typecons;

struct Nanofactory {
  auto solveFor(N, S)(N units, S chemical) {
    return tuple(0, "ANYTHING");
  }
}

auto withReactions(R)(R reactions) {
  return Nanofactory();
}

unittest {
  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(1, "ORE") == tuple(1, "ORE"));

  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(10, "ORE") == tuple(10, "ORE"));

  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(1, "FUEL") == tuple(1, "ORE"));

  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(10, "FUEL") == tuple(10, "ORE"));

  assert(withReactions([
    "3 ORE => 2 FUEL"
  ]).solveFor(5, "FUEL") == tuple(9, "ORE"));

  assert(withReactions([
    "10 ORE => 10 A"
  , "1 ORE => 1 B"
  , "7 A, 1 B => 1 C"
  , "7 A, 1 C => 1 D"
  , "7 A, 1 D => 1 E"
  , "7 A, 1 E => 1 FUEL"
  ]).solveFor(1, "FUEL") == tuple(31, "ORE"));
}

import std.typecons;

unittest {
  assert(withReactions([
    "10 ORE => 10 A"
  , "1 ORE => 1 B"
  , "7 A, 1 B => 1 C"
  , "7 A, 1 C => 1 D"
  , "7 A, 1 D => 1 E"
  , "7 A, 1 E => 1 FUEL"
  ]).solveFor(1, "FUEL") == tuple(31, "ORE"));
}
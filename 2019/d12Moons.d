struct Pt { int x, y, z; }
struct Vec { int dx, dy, dz; }
struct Moon { Pt pos; Vec vel; }

Moon toMoon(T)(T input) {
  import std.conv, std.regex;

  auto c = match(input, regex(r"<x=([-0-9]+), y=([-0-9]+), z=([-0-9]+)"));
  auto x = to!int(c.front[1]);
  auto y = to!int(c.front[2]);
  auto z = to!int(c.front[3]);

  return Moon(Pt(x, y, z));
}

unittest{
  import std.algorithm;

  assert([
    "<x=-1, y=0, z=2>"
  , "<x=2, y=-10, z=-7>"
  , "<x=4, y=-8, z=8>"
  , "<x=3, y=5, z=-1>"
  ].map!toMoon.equal([
    Moon(Pt(-1,0,2))
  , Moon(Pt(2,-10,-7))
  , Moon(Pt(4,-8,8))
  , Moon(Pt(3,5,-1))
  ]));
}

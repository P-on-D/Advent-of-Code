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

auto simulateMotion(T)(T moons) {
  foreach(ref u; moons) {
    foreach(ref v; moons) {
      import std.math;

      u.vel.dx += sgn(v.pos.x - u.pos.x);
      u.vel.dy += sgn(v.pos.y - u.pos.y);
      u.vel.dz += sgn(v.pos.z - u.pos.z);
    }
  }

  foreach(ref u; moons) {
    u.pos.x += u.vel.dx;
    u.pos.y += u.vel.dy;
    u.pos.z += u.vel.dz;
  }

  return moons;
}

unittest{
  import std.algorithm, std.array;

  auto moons = [
    "<x=-1, y=0, z=2>"
  , "<x=2, y=-10, z=-7>"
  , "<x=4, y=-8, z=8>"
  , "<x=3, y=5, z=-1>"
  ].map!toMoon.array;

  assert(moons.equal([
    Moon(Pt(-1,0,2))
  , Moon(Pt(2,-10,-7))
  , Moon(Pt(4,-8,8))
  , Moon(Pt(3,5,-1))
  ]));

  auto simulation = moons.simulateMotion;

  assert(simulation.equal([
    Moon(Pt(2,-1,1), Vec(3,-1,-1))
  , Moon(Pt(3,-7,-4), Vec(1,3,3))
  , Moon(Pt(1,-7,5), Vec(-3,1,-3))
  , Moon(Pt(2,2,0), Vec(-1,-3,1))
  ]));

  simulation.simulateMotion;

  assert(simulation.equal([
    Moon(Pt( 5, -3, -1), Vec( 3, -2, -2))
  , Moon(Pt( 1, -2,  2), Vec(-2,  5,  6))
  , Moon(Pt( 1, -4, -1), Vec( 0,  3, -6))
  , Moon(Pt( 1, -4,  2), Vec(-1, -6,  2))
  ]));

  foreach(i; 2..10) simulation.simulateMotion;

  assert(simulation.equal([
    Moon(Pt( 2,  1, -3), Vec(-3, -2,  1))
  , Moon(Pt( 1, -8,  0), Vec(-1,  1,  3))
  , Moon(Pt( 3, -6,  1), Vec( 3,  2, -3))
  , Moon(Pt( 2,  0,  4), Vec( 1, -1, -1))
  ]));
}

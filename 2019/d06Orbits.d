struct Orbits {
  int[string] indexes;
  int[] orbits;

  this(string[] input) {
    foreach(string orbitSpec; input) {
      import std.array;
      string[] spec = orbitSpec.split(")");
      string obj = spec[0];
      string satt = spec[1];

      if (!(obj in indexes)) {
        indexes[obj] = cast(int)orbits.length;
        orbits ~= cast(int)orbits.length;
      }

      indexes[satt] = cast(int)orbits.length;
      orbits ~= indexes[obj];
    }
  }

  int pathlen(int index) {
    int len;
    while(orbits[index] != index) {
      ++len;
      index = orbits[index];
    }
    return len;
  }

  int pathlen(string index) {
    return pathlen(indexes[index]);
  }

  int total() {
    int total;

    for(int i = 0; i < orbits.length; i++) {
      total += pathlen(i);
    }

    return total;
  }
}

unittest {
  auto input = [
    "COM)B"
  , "B)C"
  , "C)D"
  , "D)E"
  , "E)F"
  , "B)G"
  , "G)H"
  , "D)I"
  , "E)J"
  , "J)K"
  , "K)L"
  ];

  Orbits o = Orbits(input);

  assert(o.pathlen("D") == 3);
  assert(o.pathlen("L") == 7);
  assert(o.pathlen("COM") == 0);

  assert(o.total == 42);
} version (unittest) {} else {

void main() {
  import std.array, std.stdio;

  Orbits o = Orbits(stdin.byLineCopy.array);
  o.total.writeln;
}

}

unittest {
  int[string] indexes;
  int[] orbits;

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

  foreach(int index, string orbitSpec; input) {
    import std.array;
    string[] spec = orbitSpec.split(")");
    string obj = spec[0];
    string satt = spec[1];

    if (!(obj in indexes)) {
      indexes[obj] = index;
      orbits ~= index;
    }

    indexes[satt] = index+1;
    orbits ~= indexes[obj];
  }

  int pathlen(int index) {
    int len;
    while(orbits[index] != index) {
      ++len;
      index = orbits[index];
    }
    return len;
  }

  assert(pathlen(indexes["D"]) == 3);
  assert(pathlen(indexes["L"]) == 7);
  assert(pathlen(indexes["COM"]) == 0);

  int total;

  for(int i = 0; i < orbits.length; i++) {
    total += pathlen(i);
  }

  assert(total == 42);
}

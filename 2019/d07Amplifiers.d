unittest {
  import std.algorithm, std.range;

  assert(iota(0, 5).permutations.count == 5 * 4 * 3 * 2);
}
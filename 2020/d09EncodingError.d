// Advent of Code 2020 https://adventofcode.com/2020/day/9
// Day 9: Encoding Error

bool validNext(uint preambleLen, R)(R given, int testValue) {
  import std.algorithm : canFind, cartesianProduct, filter, map;

  auto testRange = given[$-preambleLen..$];
  return testRange.cartesianProduct(testRange)
    .filter!"a[0] != a[1]"
    .map!"a[0] + a[1]"
    .canFind(testValue);
}

unittest {
  auto given = [20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25];
  assert(given.validNext!25(26));
  assert(given.validNext!25(49));
  assert(!given.validNext!25(100));
  assert(!given.validNext!25(50));
  assert(given.validNext!25(45));

  given = given[1..$] ~ 45;
  assert(given.validNext!25(26));
  assert(!given.validNext!25(65));
  assert(given.validNext!25(64));
  assert(given.validNext!25(66));
}

void main() {}
// Advent of Code 2020 https://adventofcode.com/2020/day/9
// Day 9: Encoding Error

bool validNext(uint preambleLen, R, T)(R given, T testValue) {
  import std.algorithm : canFind, cartesianProduct, filter, map;

  auto testRange = given[$-preambleLen..$];
  return testRange.cartesianProduct(testRange)
    .filter!"a[0] != a[1]"
    .map!"a[0] + a[1]"
    .canFind(testValue);
}

auto findInvalid(uint preambleLen, R)(R given) {
  import std.range : slide;

  foreach(window; given.slide(preambleLen+1)) {
    if (!window[0..$-1].validNext!preambleLen(window[$-1])) {
      return window[$-1];
    }
  }
  assert(0);
}

unittest {
  auto given = [
    20, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 21, 22, 23, 24, 25
  ];
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

  assert(
    [35, 20, 15, 25, 47, 40, 62, 55, 65, 95, 102, 117, 150, 182, 127, 219, 299, 277, 309, 576]
    .findInvalid!5 == 127
  );
}

void main() {
  import std.algorithm : map, splitter;
  import std.array : array;
  import std.conv : to;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.map!(to!ulong).array;

  input.findInvalid!25.writeln;
}
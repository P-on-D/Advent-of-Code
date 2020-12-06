// Advent of Code 2020 https://adventofcode.com/2020/day/1
// Day 1: Report Repair

auto elementsThatSumTo(R, T)(R input, T sumTarget) {
  import std.algorithm : cartesianProduct, filter, map;
  import std.range : enumerate;
  import std.typecons : tuple;

  auto indexedInput = input.enumerate;
  return indexedInput.cartesianProduct(indexedInput)
    .filter!(a => a[0].index != a[1].index && a[0].value + a[1].value == sumTarget)
    .map!(a => tuple(a[0].value, a[1].value))
    .front;
}

auto threeElementsThatSumTo(R, T)(R input, T sumTarget) {
  import std.algorithm : cartesianProduct, filter, map;
  import std.range : enumerate;
  import std.typecons : tuple;

  auto indexedInput = input.enumerate;
  return indexedInput.cartesianProduct(indexedInput, indexedInput)
    .filter!(a => a[0].index != a[1].index && a[0].index != a[2].index && a[1].index != a[2].index)
    .filter!(a => a[0].value + a[1].value + a[2].value == sumTarget)
    .map!(a => tuple(a[0].value, a[1].value, a[2].value))
    .front;
}

unittest {
  auto input = [
    1721,
    979,
    366,
    299,
    675,
    1456
  ];

  {
    auto result = input.elementsThatSumTo(2020);
    assert(result[0] == 1721);
    assert(result[1] == 299);

    // Defend against naïve implementation
    result = [1010, 1721, 299].elementsThatSumTo(2020);
    assert(result[0] == 1721);
    assert(result[1] == 299);
  }

  {
    auto result = input.threeElementsThatSumTo(2020);
    assert(result[0] == 979);
    assert(result[1] == 366);
    assert(result[2] == 675);
  }
}

void main() {
  import std.algorithm : map, splitter;
  import std.conv : to;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.map!(to!int);
  auto result = input.elementsThatSumTo(2020);
  writeln(result[0] * result[1]);

  auto result3 = input.threeElementsThatSumTo(2020);
  writeln(result3[0] * result3[1] * result3[2]);
}

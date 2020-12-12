// Advent of Code 2020 https://adventofcode.com/2020/day/10
// Day 10: Adapter Array

auto adapterOrder(R)(R adapters) {
  import std.algorithm : joiner, maxElement, sort;
  import std.array : array;

  return [[0, adapters.maxElement + 3], adapters].joiner.array.sort;
}

auto diffs(R)(R adapters) {
  import std.algorithm : map;
  import std.range : slide;

  return adapters.slide(2).map!"a[1] - a[0]";
}

auto counts(R)(R diffs) {
  import std.algorithm : count;

  return [diffs.count!"a ==1", diffs.count!"a == 3"];
}

unittest {
  import std.algorithm : equal;

  auto input = [16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4];
  assert(input.adapterOrder.equal([0, 1, 4, 5, 6, 7, 10, 11, 12, 15, 16, 19, 22]));
  assert(input.adapterOrder.diffs.equal([1, 3, 1, 1, 1, 3, 1, 1, 3, 1, 3, 3]));
  assert(input.adapterOrder.diffs.counts.equal([7, 5]));

  assert([28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38, 39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3]
    .adapterOrder.diffs.counts.equal([22, 10]));
}

void main() {}

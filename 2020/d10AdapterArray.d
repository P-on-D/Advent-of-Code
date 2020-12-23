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

  return [diffs.count!"a == 1", diffs.count!"a == 3"];
}

auto validArrangements(R)(R orderedAdapters) {
  import std.algorithm : all, fold, map;
  import std.range : slide;
  import std.stdio;

  // My idea for efficient computation is to chunk the ordered adapter range by its fixed
  // points i.e. ends at a number 3 greater than the previous. The total is the product of
  // the valid combinations of each chunk. Only chunks with three or more elements can have
  // multiple valid arrangements based on the presence or absence of each middle element.
  auto isValid(R)(R arrangement) {
    return arrangement.slide(2).all!"a[1] - a[0] <= 3";
  }

  auto countValidArrangements(int[] chunk) {
    if (chunk.length < 3) return 1;

    auto validCount = 1;

    foreach(arrangementIndex; 0..2^^(chunk.length - 2)-1) {
      auto arrangement = [chunk[0]];
      foreach(pos; 0..chunk.length-2) {
        if(arrangementIndex & 2^^pos) {
          arrangement ~= chunk[pos+1];
        }
      }
      arrangement ~= chunk[$-1];

      if (isValid(arrangement)) {
        validCount += 1;
      }
    }

    return validCount;
  }

  // I tried a few of the built-in functions to do this but none were exactly what I
  // needed. std.algorithm.chunkBy is closest but it uses reflexive function which
  // doesn't have the correct properties, that is, the range of ranges where the next
  // element is less that 3 more than the previous.
  int[][] groups = [[orderedAdapters[0]]];

  foreach(chunk; orderedAdapters.slide(2)) {
    if (chunk[1] - chunk[0] < 3) {
      groups[$-1] ~= chunk[1];
    } else {
      groups ~= [chunk[1]];
    }
  }

  return groups.map!countValidArrangements.fold!"a * b";
}

unittest {
  import std.algorithm : equal;

  auto order = adapterOrder([16, 10, 15, 5, 1, 11, 7, 19, 6, 12, 4]);
  assert(order.equal([0, 1, 4, 5, 6, 7, 10, 11, 12, 15, 16, 19, 22]));
  assert(order.diffs.equal([1, 3, 1, 1, 1, 3, 1, 1, 3, 1, 3, 3]));
  assert(order.diffs.counts.equal([7, 5]));
  assert(order.validArrangements == 8);

  order = adapterOrder([28, 33, 18, 42, 31, 14, 46, 20, 48, 47, 24, 23, 49, 45, 19, 38, 39, 11, 1, 32, 25, 35, 8, 17, 7, 9, 4, 2, 34, 10, 3]);
  assert(order.diffs.counts.equal([22, 10]));
  assert(order.validArrangements == 19208);
}

void main() {
  import std.algorithm : fold, map, splitter;
  import std.array : array;
  import std.conv : to;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.map!(to!int).array;
  input.adapterOrder.diffs.counts.fold!"a * b".writeln;
}

// Advent of Code 2020 https://adventofcode.com/2020/day/5
// Day 5: Binary Boarding

auto seatID(R)(R input) {
  import std.algorithm : map;
  import std.conv : to;

  return input
    .map!(ch => (ch == 'F' || ch == 'L') ? '0' : '1')
    .to!int(2);
}

auto missingID(R)(R input) {
  import std.algorithm : minElement, maxElement, find, canFind;
  import std.range : front, iota;

  return iota(input.minElement, input.maxElement)
    .find!(id => !input.canFind(id))
    .front;
}

unittest {
  assert("FBFBBFFRLR".seatID == 357);
  assert("BFFFBBFRRR".seatID == 567);
  assert("FFFBBBFRRR".seatID == 119);
  assert("BBFFBBFRLL".seatID == 820);

  assert([1,2,3,5,6].missingID == 4);
  assert([10,8,7].missingID == 9);
}

void main() {
  import std.algorithm : map, maxElement, splitter;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  data.map!seatID.maxElement.writeln;
}

// Advent of Code 2020 https://adventofcode.com/2020/day/13
// Day 13: Shuttle Search

auto earliestBusAndWaitTime(string[] input) in (input.length >= 2) {
  import std.algorithm : filter, map, minElement, splitter;
  import std.conv : to;
  import std.math : sgn;

  auto earliestDepart = to!uint(input[0]);
  auto busIDs = input[1].splitter(",").filter!(id => id != "x").map!(to!uint);

  uint[2] firstBus(uint id) {
    uint r = sgn(earliestDepart % id);
    uint d = earliestDepart / id;
    uint nextBus = id * (d + r);
    uint wait = nextBus - earliestDepart;
    return [id, wait];
  }

  return busIDs
    .map!firstBus
    .minElement!"a[1]";
}

unittest {
  auto input = [
    "939",
    "7,13,x,x,59,x,31,19",
  ];

  assert(input.earliestBusAndWaitTime == [59, 5]);
}

void main() {
  import std.algorithm : fold, map, splitter;
  import std.array : array;
  import std.conv : to;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.map!(to!string).array;

  input.earliestBusAndWaitTime.fold!"a * b".writeln;
}

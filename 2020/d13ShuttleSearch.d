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

auto earliestCongruentDeparture(string[] input, ulong minLimit = 0) in (input.length >= 2) {
  import std.algorithm : all, filter, map, maxElement, remove, splitter;
  import std.array : array;
  import std.conv : to;
  import std.math : sgn;
  import std.range : enumerate;

  auto busIDs = input[1]
    .splitter(",")
    .enumerate
    .filter!(id => id[1] != "x")
    .map!(id => [id[0], to!ulong(id[1])])
    .array;

  ulong congruentDeparture(ulong[] busID, ulong testDeparture) {
    auto id = busID[1];
    ulong r = sgn(testDeparture % id);
    ulong d = testDeparture / id;
    ulong nextBus = id * (d + r);
    return nextBus - busID[0];
  }

  bool congruent(ulong[][] busIDs, ulong testDeparture) {
    return busIDs
      .map!(id => congruentDeparture(id, testDeparture))
      .all!(a => a == testDeparture);
  }

  ulong[2] stepElement = busIDs.maxElement!"a[1]";
  busIDs = busIDs.remove!(a => a == stepElement);

  ulong step = minLimit / stepElement[1], testDeparture = 0;

  do {
    step += 1;
    testDeparture = (step * stepElement[1]) - stepElement[0];
  } while(!congruent(busIDs, testDeparture));

  return testDeparture;
}

unittest {
  auto input = [
    "939",
    "7,13,x,x,59,x,31,19",
  ];

  assert(input.earliestBusAndWaitTime == [59, 5]);

  assert(input.earliestCongruentDeparture == 1068781);
  assert(["", "17,x,13,19"].earliestCongruentDeparture == 3417);
  assert(["", "67,7,59,61"].earliestCongruentDeparture == 754018);
  assert(["", "67,x,7,59,61"].earliestCongruentDeparture == 779210);
  assert(["", "67,7,x,59,61"].earliestCongruentDeparture == 1261476);
  assert(["", "1789,37,47,1889"].earliestCongruentDeparture == 1202161486);
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

// Advent of Code 2020 https://adventofcode.com/2020/day/5
// Day 5: Binary Boarding

auto seatID(R)(R input) {
  import std.algorithm : map;
  import std.conv : to;

  return input
    .map!(ch => (ch == 'F' || ch == 'L') ? '0' : '1')
    .to!int(2);
}

unittest {
  assert("FBFBBFFRLR".seatID == 357);
  assert("BFFFBBFRRR".seatID == 567);
  assert("FFFBBBFRRR".seatID == 119);
  assert("BBFFBBFRLL".seatID == 820);
}

void main() {}

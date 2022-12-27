// Advent of Code 2022 https://adventofcode.com/2022/day/6
// Day 6: Tuning Trouble

bool isMarkerString(T)(T candidate) {
  import std.conv : to;
  import std.algorithm : sort, isStrictlyMonotonic;

  return candidate.to!(dchar[]).sort.isStrictlyMonotonic;
}

size_t firstMarkerPos(T)(T input) {
  import std.algorithm : countUntil;
  import std.range : slide;

  return input
    .slide(4)
    .countUntil!isMarkerString
    + 4;
}

unittest {
  assert("mjqjpqmgbljsphdztnvjfqwrcgsmlb".firstMarkerPos == 7);

  assert("bvwbjplbgvbhsrlpgdmjqwftvncz".firstMarkerPos == 5);
  assert("nppdvjthqldpwncqszvftbrmjlhg".firstMarkerPos == 6);
  assert("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg".firstMarkerPos == 10);
  assert("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw".firstMarkerPos == 11);
}

void main() {
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt"));

  data.firstMarkerPos.writeln;
}

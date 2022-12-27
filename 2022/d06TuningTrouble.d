// Advent of Code 2022 https://adventofcode.com/2022/day/6
// Day 6: Tuning Trouble

bool isMarkerString(T)(T candidate) {
  import std.conv : to;
  import std.algorithm : sort, isStrictlyMonotonic;

  return candidate.to!(dchar[]).sort.isStrictlyMonotonic;
}

size_t firstMarkerPos(T)(T input, size_t windowSize = 4) {
  import std.algorithm : countUntil;
  import std.range : slide;

  return input
    .slide(windowSize)
    .countUntil!isMarkerString
    + windowSize;
}

unittest {
  assert("mjqjpqmgbljsphdztnvjfqwrcgsmlb".firstMarkerPos == 7);

  assert("bvwbjplbgvbhsrlpgdmjqwftvncz".firstMarkerPos == 5);
  assert("nppdvjthqldpwncqszvftbrmjlhg".firstMarkerPos == 6);
  assert("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg".firstMarkerPos == 10);
  assert("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw".firstMarkerPos == 11);

  assert("mjqjpqmgbljsphdztnvjfqwrcgsmlb".firstMarkerPos(14) == 19);
  assert("bvwbjplbgvbhsrlpgdmjqwftvncz".firstMarkerPos(14) == 23);
  assert("nppdvjthqldpwncqszvftbrmjlhg".firstMarkerPos(14) == 23);
  assert("nznrnfrfntjfmvfwmzdfjlvtqnbhcprsg".firstMarkerPos(14) == 29);
  assert("zcfzfwzzqfrljwzlrfnpqdbhtmscgvjw".firstMarkerPos(14) == 26);
}

void main() {
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt"));

  data.firstMarkerPos.writeln;
}

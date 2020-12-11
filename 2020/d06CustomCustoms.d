// Advent of Code 2020 https://adventofcode.com/2020/day/6
// Day 6: Custom Customs

auto yesAnswers(R)(R input) {
  import std.algorithm, std.array, std.range;

  return input.joiner.array.sort.uniq.count;
}

unittest {
  assert(["abcx", "abcy" , "abcz"].yesAnswers == 6);
  assert(["abc"].yesAnswers == 3);
  assert(["a", "b", "c"].yesAnswers == 3);
  assert(["ab", "ac"].yesAnswers == 3);
  assert(["a", "a", "a", "a"].yesAnswers == 1);
  assert(["b"].yesAnswers == 1);
}

void main() {
  import std.array : array;
  import std.algorithm : map, splitter, sum;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.array.splitter("");

  input.map!yesAnswers.sum.writeln;
}
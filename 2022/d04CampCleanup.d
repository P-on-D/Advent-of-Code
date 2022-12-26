// Advent of Code 2022 https://adventofcode.com/2022/day/4
// Day 4: Camp Cleanup

struct Pair(T) { T fst; T snd; }
alias Assignment = Pair!(Pair!uint);

Assignment parse(string assignment) {
  import std.format : formattedRead;

  Assignment a;
  assignment.formattedRead("%d-%d,%d-%d", a.fst.fst, a.fst.snd, a.snd.fst, a.snd.snd);
  return a;
}

bool fullyContained(Assignment a) {
  return (a.fst.fst <= a.snd.fst && a.fst.snd >= a.snd.snd)
      || (a.snd.fst <= a.fst.fst && a.snd.snd >= a.fst.snd)
  ;
}

unittest {
  auto sampleData1 = [
    "2-4,6-8",
    "2-3,4-5",
    "5-7,7-9",
    "2-8,3-7",
    "6-6,4-6",
    "2-6,4-8",
  ];

  import std.algorithm, std.format, std.stdio;

  assert(sampleData1.map!parse.count!fullyContained == 2);
}

void main() {
  import std.algorithm : count, map, splitter;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");

  data.map!parse.count!fullyContained.writeln;
}
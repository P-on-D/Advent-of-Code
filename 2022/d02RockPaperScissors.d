// Advent of Code 2022 https://adventofcode.com/2022/day/2
// Day 2: Rock Paper Scissors

enum scoreTable = [
  "A X": 1 + 3,
  "B X": 1,
  "C X": 1 + 6,
  "A Y": 2 + 6,
  "B Y": 2 + 3,
  "C Y": 2,
  "A Z": 3,
  "B Z": 3 + 6,
  "C Z": 3 + 3,
];

enum decryptedTable = [
  "A X": 3,
  "B X": 1,
  "C X": 2,
  "A Y": 3 + 1,
  "B Y": 3 + 2,
  "C Y": 3 + 3,
  "A Z": 6 + 2,
  "B Z": 6 + 3,
  "C Z": 6 + 1,
];

unittest {
  auto sampleData1 = [
    "A Y",
    "B X",
    "C Z"
  ];

  import std.algorithm;

  assert(sampleData1.map!(round => scoreTable[round]).sum == 15);
  assert(sampleData1.map!(round => decryptedTable[round]).sum == 12);
}

void main() {
  import std.algorithm : map, sum, splitter;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");

  data.map!(round => scoreTable[round]).sum.writeln;
  data.map!(round => decryptedTable[round]).sum.writeln;
}

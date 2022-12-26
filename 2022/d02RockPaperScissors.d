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
unittest {
  auto sampleData1 = [
    "A Y",
    "B X",
    "C Z"
  ];

  import std.algorithm;

  assert(sampleData1.map!(round => scoreTable[round]).sum == 15);
}

void main() {}

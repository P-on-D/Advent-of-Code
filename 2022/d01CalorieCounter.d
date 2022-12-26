// Advent of Code 2022 https://adventofcode.com/2022/day/1
// Day 1: Calorie Counting

unittest {
  auto sampleData1 = [
    "1000",
    "2000",
    "3000",
    "",
    "4000",
    "",
    "5000",
    "6000",
    "",
    "7000",
    "8000",
    "9000",
    "",
    "10000"
  ];

  import std.algorithm, std.array, std.conv;

  auto input1 = sampleData1.split("");

  assert(input1.length == 5);
  assert(input1[0] == ["1000", "2000", "3000"]);
  assert(input1[4] == ["10000"]);

  auto elvenCalories = input1
    .map!(map!(to!ulong))
    .map!sum
    .array
  ;

  assert(elvenCalories == [6000, 4000, 11000, 24000, 10000]);

  auto largestCalories = elvenCalories.maxElement;

  assert(largestCalories == 24000);
}

void main() {
}

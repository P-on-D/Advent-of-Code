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

  import std.algorithm, std.array, std.conv, std.range;

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

  auto topThreeCaloriesSum = elvenCalories
    .sort!"a > b"
    .take(3)
    .sum
  ;

  assert(topThreeCaloriesSum == 45000);
}

void main() {
  import std.algorithm : map, sum, sort, splitter, maxElement;
  import std.array : array, split;
  import std.conv : to;
  import std.path : setExtension;
  import std.range : take;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");

  auto elvenCalories = data
    .array
    .split("")
    .map!(map!(to!ulong))
    .map!sum
  ;

  writeln(elvenCalories.maxElement);

  auto topThreeCaloriesSum = elvenCalories
    .array
    .sort!"a > b"
    .take(3)
    .sum
  ;
  writeln(topThreeCaloriesSum);
}

// Advent of Code 2022 https://adventofcode.com/2022/day/3
// Day 3: Rucksack Reorganisation

auto toRucksack(string items) {
  import std.algorithm, std.conv;

  return items.to!(dchar[]).sort.uniq;
}

string commonBetweenRucksacks(string rucksack1, string rucksack2) {
  import std.algorithm, std.array, std.conv;
  return toRucksack(rucksack1).setIntersection(toRucksack(rucksack2)).to!string;
}

auto toPriority(dchar x) {
  return x <= 'Z' ? x - 'A' + 27 : x - 'a' + 1;
}

unittest {
  auto sampleData1 = [
    "vJrwpWtwJgWrhcsFMMfFFhFp",
    "jqHRNqRjqzjGDLGLrsFMfFZSrLrFZsSL",
    "PmmdzqPrVvPwwTWBwg",
    "wMqvLMZHhHMvwLHjbvcjnnSBnvTQFn",
    "ttgJtRGJQctTZtZT",
    "CrZsJsPPZsGzwwsLwLmpwMDw",
  ];

  auto firstHalfFirstRucksack = sampleData1[0][0..$/2];
  auto secondHalfFirstRucksack = sampleData1[0][$/2..$];

  import std.array, std.algorithm, std.conv, std.range;

  assert(firstHalfFirstRucksack.length == secondHalfFirstRucksack.length);
  assert(commonBetweenRucksacks(firstHalfFirstRucksack, secondHalfFirstRucksack)
    == "p"
  );
  assert(sampleData1.map!(input => commonBetweenRucksacks(input[0..$/2], input[$/2..$]))
    .join
    == "pLPvts");
  assert(sampleData1.map!(input => commonBetweenRucksacks(input[0..$/2], input[$/2..$]))
    .join
    .map!toPriority
    .sum
    == 157);

  assert(commonBetweenRucksacks(
    sampleData1[0],
    commonBetweenRucksacks(
      sampleData1[1],
      sampleData1[2]
    )
  ) == "r");

  assert(sampleData1.chunks(3)[1].fold!commonBetweenRucksacks == "Z");

  assert(sampleData1.chunks(3).map!(fold!commonBetweenRucksacks).map!("a[0]").map!toPriority.sum == 70);
}

void main() {
  import std.algorithm : fold, map, sum, splitter;
  import std.array : join;
  import std.path : setExtension;
  import std.range : front, chunks;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");

  data.map!(input => commonBetweenRucksacks(input[0..$/2], input[$/2..$]))
    .join
    .map!toPriority
    .sum
    .writeln
  ;

  data.chunks(3)
    .map!(fold!commonBetweenRucksacks)
    .map!front
    .map!toPriority
    .sum
    .writeln
  ;
}
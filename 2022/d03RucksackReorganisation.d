// Advent of Code 2022 https://adventofcode.com/2022/day/3
// Day 3: Rucksack Reorganisation

auto toRucksack(string items) {
  import std.algorithm, std.conv;

  return items.to!(dchar[]).sort.uniq;
}

auto commonBetweenRucksacks(string rucksack1, string rucksack2) {
  import std.algorithm, std.array;
  return toRucksack(rucksack1).setIntersection(toRucksack(rucksack2)).array;
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

  import std.array, std.algorithm;

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
}

void main() {}
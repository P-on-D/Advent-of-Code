// Advent of Code 2020 https://adventofcode.com/2020/day/4
// Day 4: Passport Processing

enum requiredFields = ["ecl", "pid", "eyr", "hcl", "byr", "iyr", "hgt"];

auto parsePassportBatch(R)(R input) {
  import std.algorithm : map, splitter;
  import std.array : join;

  return input
    .splitter("")
    .map!(chunk => chunk.join(" "));
}

auto passportValid(string line) {
  import std.algorithm : all, canFind, map, splitter;
  import std.range : front;

  auto keys = line.splitter(' ').map!(pair => pair.splitter(':').front);

  return requiredFields.all!(k => keys.canFind(k));
}

unittest {
  import std.algorithm : count, equal, map;

  auto input = [
    "ecl:gry pid:860033327 eyr:2020 hcl:#fffffd",
    "byr:1937 iyr:2017 cid:147 hgt:183cm",
    "",
    "iyr:2013 ecl:amb cid:350 eyr:2023 pid:028048884",
    "hcl:#cfa07d byr:1929",
    "",
    "hcl:#ae17e1 iyr:2013",
    "eyr:2024",
    "ecl:brn pid:760753108 byr:1931",
    "hgt:179cm",
    "",
    "hcl:#cfa07d eyr:2025 pid:166559648",
    "iyr:2011 ecl:brn hgt:59in"
  ];

  auto passportLines = input.parsePassportBatch;
  assert(passportLines.count == 4);

  auto validity = passportLines.map!passportValid;
  assert(validity.equal([true, false, true, false]));
}

void main() {}

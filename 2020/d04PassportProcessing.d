// Advent of Code 2020 https://adventofcode.com/2020/day/4
// Day 4: Passport Processing

auto parsePassportBatch(R)(R input) {
  import std.algorithm : joiner, map, splitter;

  return input
    .splitter("")
    .map!(chunk => chunk.joiner(" "));
}

unittest {
  import std.algorithm : count;

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

  assert(input.parsePassportBatch.count == 4);
}

void main() {}

// Advent of Code 2020 https://adventofcode.com/2020/day/2
// Day 2: Password Philosophy

struct Policy {
  uint minCount, maxCount;
  char letter;
}

struct DatabaseEntry {
  Policy policy;
  string password;
}

DatabaseEntry parseToDatabaseEntry(T)(T line) {
  import std.exception : enforce;
  import std.format : formattedRead;

  DatabaseEntry d;
  enforce(
    4 == line.formattedRead!"%d-%d %s: %s"(
      d.policy.minCount,
      d.policy.maxCount,
      d.policy.letter,
      d.password
    )
  );
  return d;
}

bool validate(DatabaseEntry d) {
  import std.algorithm : count;

  auto occurrences = d.password.count(d.policy.letter);
  return occurrences >= d.policy.minCount && occurrences <= d.policy.maxCount;
}

unittest {
  import std.algorithm : map;

  auto input = [
    "1-3 a: abcde",
    "1-3 b: cdefg",
    "2-9 c: ccccccccc"
  ];

  auto parsed = input.map!parseToDatabaseEntry;
  assert(parsed[0] == DatabaseEntry(Policy(1, 3, 'a'), "abcde"));
  assert(parsed[1] == DatabaseEntry(Policy(1, 3, 'b'), "cdefg"));
  assert(parsed[2] == DatabaseEntry(Policy(2, 9, 'c'), "ccccccccc"));

  assert(parsed[0].validate);
  assert(!parsed[1].validate);
  assert(parsed[2].validate);
}

void main() {}
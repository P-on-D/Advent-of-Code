// Advent of Code 2020 https://adventofcode.com/2020/day/4
// Day 4: Passport Processing

class PassportValidator {
  import std.range, std.regex;

  alias validator = bool function (string);

  static auto isYearBetween(string value, uint low, uint high) {
    import std.conv : to;

    auto match = matchFirst(value, `^\d{4}$`);
    if (match.empty) return false;
    auto year = to!int(match.hit);
    return year >= low && year <= high;
  }

  static auto heightValidator(string value) {
    import std.conv : to;

    auto match = matchFirst(value, `^(\d+)(cm|in)$`);
    if (match.length != 3) return false;

    auto height = to!int(match[1]);
    return (match[2] == "cm" && height >= 150 && height <= 193)
      || (match[2] == "in" && height >= 59 && height <= 76);
  }

  validator eyeColourValid = (string value) => !matchFirst(value, `^(amb|blu|brn|gry|grn|hzl|oth)$`).empty;
  validator passportIdValid = (string value) => !matchFirst(value, `^\d{9}$`).empty;
  validator expiryYearValid = (string value) => isYearBetween(value, 2020, 2030);
  validator hairColourValid = (string value) => !matchFirst(value, `^#[0-9a-f]{6}$`).empty;
  validator birthYearValid = (string value) => isYearBetween(value, 1920, 2002);
  validator issueYearValid = (string value) => isYearBetween(value, 2010, 2020);
  validator heightValid = (string value) => heightValidator(value);

  private validator*[string] requiredFields;

  this() {
    this.requiredFields = [
      "ecl": &eyeColourValid,
      "pid": &passportIdValid,
      "eyr": &expiryYearValid,
      "hcl": &hairColourValid,
      "byr": &birthYearValid,
      "iyr": &issueYearValid,
      "hgt": &heightValid
    ];
  }

  auto keysValid(string line) {
    import std.algorithm : all, canFind, map, splitter;

    auto keys = line.splitter(' ').map!(pair => pair.splitter(':').front);

    return this.requiredFields.keys.all!(k => keys.canFind(k));
  }

  private auto valuesValid(string line) {
    import std.algorithm : all, find, map, splitter;
    import std.string : split;

    auto pairs = line.splitter(' ').map!(pair => pair.split(':'));

    return this.requiredFields.byKeyValue()
      .all!(rf => (*rf.value)(pairs.find!(a => a[0] == rf.key).front[1]));
  }

  auto valid(string line) {
    return this.keysValid(line) && this.valuesValid(line);
  }
}

auto parsePassportBatch(R)(R input) {
  import std.algorithm : map, splitter;
  import std.array : join;

  return input
    .splitter("")
    .map!(chunk => chunk.join(" "));
}

unittest {
  import std.algorithm : all, count, equal, map;

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

  auto validator = new PassportValidator;
  auto validity = passportLines.map!(l => validator.keysValid(l));
  assert(validity.equal([true, false, true, false]));

  assert(validator.eyeColourValid("hzl"));
  assert(!validator.eyeColourValid("ambblu"));

  assert(validator.passportIdValid("000000009"));
  assert(!validator.passportIdValid("1000000009"));

  assert(validator.expiryYearValid("2025"));
  assert(!validator.expiryYearValid("2019"));
  assert(!validator.expiryYearValid("2031"));
  assert(!validator.expiryYearValid("201"));
  assert(!validator.expiryYearValid("12019"));

  assert(validator.hairColourValid("#abc123"));
  assert(!validator.hairColourValid("abc123"));
  assert(!validator.hairColourValid("#abc1234"));
  assert(!validator.hairColourValid("#FFFFFF"));

  assert(validator.birthYearValid("1999"));
  assert(!validator.birthYearValid("1919"));
  assert(!validator.birthYearValid("2003"));
  assert(!validator.birthYearValid("201"));

  assert(validator.issueYearValid("2015"));
  assert(!validator.issueYearValid("2009"));
  assert(!validator.issueYearValid("2021"));
  assert(!validator.issueYearValid("201"));

  assert(!validator.heightValid("149cm"));
  assert(validator.heightValid("150cm"));
  assert(validator.heightValid("170cm"));
  assert(validator.heightValid("193cm"));
  assert(!validator.heightValid("194cm"));
  assert(!validator.heightValid("64cm"));
  assert(!validator.heightValid("193"));

  assert(!validator.heightValid("58in"));
  assert(validator.heightValid("59in"));
  assert(validator.heightValid("65in"));
  assert(validator.heightValid("76in"));
  assert(!validator.heightValid("77in"));
  assert(!validator.heightValid("76"));

  auto invalidPassports = [
    "eyr:1972 cid:100",
    "hcl:#18171d ecl:amb hgt:170 pid:186cm iyr:2018 byr:1926",
    "",
    "iyr:2019",
    "hcl:#602927 eyr:1967 hgt:170cm",
    "ecl:grn pid:012533040 byr:1946",
    "",
    "hcl:dab227 iyr:2012",
    "ecl:brn hgt:182cm pid:021572410 eyr:2020 byr:1992 cid:277",
    "",
    "hgt:59cm ecl:zzz",
    "eyr:2038 hcl:74454a iyr:2023",
    "pid:3556412378 byr:2007"
  ];
  assert(!invalidPassports.parsePassportBatch.map!(l => validator.valid(l)).all);

  auto validPassports = [
    "pid:087499704 hgt:74in ecl:grn iyr:2012 eyr:2030 byr:1980",
    "hcl:#623a2f",
    "",
    "eyr:2029 ecl:blu cid:129 byr:1989",
    "iyr:2014 pid:896056539 hcl:#a97842 hgt:165cm",
    "",
    "hcl:#888785",
    "hgt:164cm byr:2001 iyr:2015 cid:88",
    "pid:545766238 ecl:hzl",
    "eyr:2022",
    "",
    "iyr:2010 hgt:158cm hcl:#b6652a ecl:blu byr:1944 eyr:2021 pid:093154719"
  ];
  assert(validPassports.parsePassportBatch.map!(l => validator.valid(l)).all);
}

void main() {
  import std.algorithm : count, filter, splitter;
  import std.array : array;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.array.parsePassportBatch;

  auto validator = new PassportValidator;
  input.filter!(l => validator.keysValid(l)).count.writeln;
  input.filter!(l => validator.valid(l)).count.writeln;
}

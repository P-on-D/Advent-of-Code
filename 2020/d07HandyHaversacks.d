// Advent of Code 2020 https://adventofcode.com/2020/day/7
// Day 7: Handy Haversacks

struct Contains { uint count; string type; }
struct Container { string type; Contains[] contains; }

Container parseContainer(string input) {
  import std.conv : to;
  import std.regex;

  static containerRx = ctRegex!(`^(.+) bags contain (.+)\.$`);
  static containsRx = ctRegex!(`(\d+) (.+?) bags?(?:, )?`);

  Container container;

  auto outer = input.matchFirst(containerRx);

  if (outer.length == 3) {
    container.type = outer[1];

    foreach(inner; outer[2].matchAll(containsRx)) {
      container.contains ~= Contains(to!uint(inner[1]), inner[2]);
    }
  }

  return container;
}

unittest {
  import std.algorithm : equal, map;

  auto input = [
    "light red bags contain 1 bright white bag, 2 muted yellow bags.",
    "dark orange bags contain 3 bright white bags, 4 muted yellow bags.",
    "bright white bags contain 1 shiny gold bag.",
    "muted yellow bags contain 2 shiny gold bags, 9 faded blue bags.",
    "shiny gold bags contain 1 dark olive bag, 2 vibrant plum bags.",
    "dark olive bags contain 3 faded blue bags, 4 dotted black bags.",
    "vibrant plum bags contain 5 faded blue bags, 6 dotted black bags.",
    "faded blue bags contain no other bags.",
    "dotted black bags contain no other bags."
  ];

  assert(input.map!parseContainer.equal([
    Container("light red", [Contains(1, "bright white"), Contains(2, "muted yellow")]),
    Container("dark orange", [Contains(3, "bright white"), Contains(4, "muted yellow")]),
    Container("bright white", [Contains(1, "shiny gold")]),
    Container("muted yellow", [Contains(2, "shiny gold"), Contains(9, "faded blue")]),
    Container("shiny gold", [Contains(1, "dark olive"), Contains(2, "vibrant plum")]),
    Container("dark olive", [Contains(3, "faded blue"), Contains(4, "dotted black")]),
    Container("vibrant plum", [Contains(5, "faded blue"), Contains(6, "dotted black")]),
    Container("faded blue", []),
    Container("dotted black", [])
  ]));
}

void main() {}
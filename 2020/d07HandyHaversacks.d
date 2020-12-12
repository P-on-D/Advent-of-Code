// Advent of Code 2020 https://adventofcode.com/2020/day/7
// Day 7: Handy Haversacks

struct Content { uint count; string type; }
struct Container {
  string type;
  Content[] content;

  bool contains(string type) {
    import std.algorithm : canFind;

    return content.canFind!(c => c.type == type);
  }
}

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
      container.content ~= Content(to!uint(inner[1]), inner[2]);
    }
  }

  return container;
}

auto thatContain(R)(R containers, string type) {
  import std.algorithm : filter;

  return containers.filter!(c => c.contains(type));
}

Container[] allThatContain(R)(R containers, string type) {
  import std.algorithm : map, sort, uniq;
  import std.array : array, join;

  Container[] canContain = containers.thatContain(type).array;

  if (canContain.length) {
    canContain ~= canContain.map!(c => containers.allThatContain(c.type)).join;
  }

  return canContain.sort!"a.type < b.type".uniq!"a.type == b.type".array;
}

uint totalBagsInside(R)(R containers, string type) {
  import std.algorithm : each, find;

  uint total;
  auto bag = containers.find!"a.type == b"(type);

  if (!bag.empty) {
    bag.front.content.each!(c => total += c.count + c.count * containers.totalBagsInside(c.type));
  }

  return total;
}

unittest {
  import std.algorithm : equal, map, sort, uniq;
  import std.array : array;

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
    Container("light red", [Content(1, "bright white"), Content(2, "muted yellow")]),
    Container("dark orange", [Content(3, "bright white"), Content(4, "muted yellow")]),
    Container("bright white", [Content(1, "shiny gold")]),
    Container("muted yellow", [Content(2, "shiny gold"), Content(9, "faded blue")]),
    Container("shiny gold", [Content(1, "dark olive"), Content(2, "vibrant plum")]),
    Container("dark olive", [Content(3, "faded blue"), Content(4, "dotted black")]),
    Container("vibrant plum", [Content(5, "faded blue"), Content(6, "dotted black")]),
    Container("faded blue", []),
    Container("dotted black", [])
  ]));

  auto containers = input.map!parseContainer;

  assert(containers.thatContain("shiny gold").map!"a.type".array.sort.equal([
    "bright white", "muted yellow"
  ]));

  assert(containers.allThatContain("shiny gold").map!"a.type".equal([
    "bright white", "dark orange", "light red", "muted yellow"
  ]));

  assert(containers.totalBagsInside("shiny gold") == 32);
  assert([
    "shiny gold bags contain 2 dark red bags.",
    "dark red bags contain 2 dark orange bags.",
    "dark orange bags contain 2 dark yellow bags.",
    "dark yellow bags contain 2 dark green bags.",
    "dark green bags contain 2 dark blue bags.",
    "dark blue bags contain 2 dark violet bags.",
    "dark violet bags contain no other bags."
  ].map!parseContainer.totalBagsInside("shiny gold") == 126);
}

void main() {
  import std.algorithm : map, splitter;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto containers = data.map!parseContainer;
  containers.allThatContain("shiny gold").length.writeln;
  containers.totalBagsInside("shiny gold").writeln;
}
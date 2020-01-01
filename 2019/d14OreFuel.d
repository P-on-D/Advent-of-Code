import std.algorithm, std.array, std.range, std.typecons;

alias Units = uint;
alias Symbol = string;

struct Quantity {
  Units units;
  Symbol of;
}

struct Reaction {
  Quantity qty;
  Quantity[] requires;
}

struct Nanofactory {
  Reaction[] reactions;

  auto solveFor(Quantity required) {
    auto sources = reactions.find!(r => r.qty.of == required.of);
    if (!sources.empty) {
      return sources[0].requires[0];
    }
    return required;
  }
}

auto withReactions(R)(R reactions) {
  import std.conv, std.regex;

  // match order is;
  //   0: all
  //   1: 1st requirement, 2: unit, 3: symbol
  //   4-6: 2nd requirement if present, and so on
  // $-3: output, $-2: unit, $-1: symbol
  auto rxReaction = regex(r"( ?(\d+) (\w+),?)+ => ((\d+) (\w+))");

  Quantity toQty(R)(R matches) {
    return Quantity(
      matches.dropOne.front.to!Units  // matches[1]
    , matches.dropOne.front.to!Symbol // matches[2]
    );
  }

  auto parser(string reactionSpec) {
    auto matches = reactionSpec.matchFirst(rxReaction);
    if (matches[0]) {
      matches.popFront;
      auto quantities = matches.chunks(3).map!(ch => toQty(ch)).array;
      return Reaction(quantities.back, quantities.dropBackOne);
    }
    return Reaction();
  }

  return Nanofactory(reactions.map!(parser).array);
}

unittest {
  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(Quantity(1, "ORE")) == Quantity(1, "ORE"));

  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(Quantity(10, "ORE")) == Quantity(10, "ORE"));

  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(Quantity(1, "FUEL")) == Quantity(1, "ORE"));

  assert(withReactions([
    "1 ORE => 1 FUEL"
  ]).solveFor(Quantity(10, "FUEL")) == Quantity(10, "ORE"));

  assert(withReactions([
    "3 ORE => 2 FUEL"
  ]).solveFor(Quantity(5, "FUEL")) == Quantity(9, "ORE"));

  assert(withReactions([
    "10 ORE => 10 A"
  , "1 ORE => 1 B"
  , "7 A, 1 B => 1 C"
  , "7 A, 1 C => 1 D"
  , "7 A, 1 D => 1 E"
  , "7 A, 1 E => 1 FUEL"
  ]).solveFor(Quantity(1, "FUEL")) == Quantity(31, "ORE"));
}

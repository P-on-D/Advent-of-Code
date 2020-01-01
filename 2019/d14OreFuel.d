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

  Quantity[] solveOne(Quantity required) {
    auto sources = reactions.find!(r => r.qty.of == required.of);
    if (!sources.empty) {
      Reaction reaction = sources.front;

      auto scale = (required.units / reaction.qty.units) + (required.units % reaction.qty.units != 0);
      return reaction.requires.map!(r => Quantity(r.units * scale, r.of)).array;
    }

    return [required];
  }

  bool isBase(Symbol s) {
    auto r = reactions.find!(r => r.qty.of == s);
    return r.empty
      ? true
      : !reactions.canFind!(r2 => r2.qty.of == r.front.requires.front.of);
  }

  Quantity solveFor(Quantity required) {
    Quantity[] previousSolution = [];
    Quantity[] solution = solveOne(required);

    while(solution != previousSolution) {
      previousSolution = solution;
      solution = solution.map!(req => isBase(req.of) ? [req] : solveOne(req)).array.join;
    }

    Quantity sumOf(Quantity[] sameOf) {
      Symbol of = sameOf.front.of;
      return Quantity(sameOf.map!"a.units".sum, of);
    }

    solution = solution
        .sort!"a.of < b.of"
        .chunkBy!"a.of == b.of"
        .map!(c => sumOf(c.array))
        .map!(req => solveOne(req))
        .array.join;

    return sumOf(solution);
  }
}

auto withReactions(R)(R reactions) {
  import std.conv;

  Quantity toQty(string s) {
    auto parts = s.split(" ");
    return Quantity(parts[0].to!Units , parts[1].to!Symbol);
  }

  auto parser(string reactionSpec) {
    auto parts = reactionSpec.split(" => ");
    auto reqs = parts[0].split(", ");
    return Reaction(
      toQty(parts[1])
    , reqs.map!(r => toQty(r)).array
    );
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
    "3 ORE => 17 FUEL"
  ]).solveFor(Quantity(5, "FUEL")) == Quantity(3, "ORE"));

  auto oneFuel = Quantity(1, "FUEL");

  assert(withReactions([
    "1 ORE => 1 WISH"
  , "1 WISH => 1 FUEL"
  ]).solveFor(oneFuel) == Quantity(1, "ORE"));

  assert(withReactions([
    "1 ORE => 1 CHORE"
  , "1 CHORE => 1 WISH"
  , "2 WISH => 1 FISH"
  , "2 FISH => 1 DISH"
  , "2 DISH => 1 DAMAGE"
  , "4 DAMAGE => 1 CRUEL"
  , "2 CRUEL => 1 FUEL"
  ]).solveFor(oneFuel) == Quantity(64, "ORE"));

  assert(withReactions([
    "10 ORE => 10 A"
  , "1 ORE => 1 B"
  , "7 A, 1 B => 1 C"
  , "7 A, 1 C => 1 D"
  , "7 A, 1 D => 1 E"
  , "7 A, 1 E => 1 FUEL"
  ]).solveFor(oneFuel) == Quantity(31, "ORE"));

  assert(withReactions([
    "9 ORE => 2 A"
  , "8 ORE => 3 B"
  , "7 ORE => 5 C"
  , "3 A, 4 B => 1 AB"
  , "5 B, 7 C => 1 BC"
  , "4 C, 1 A => 1 CA"
  , "2 AB, 3 BC, 4 CA => 1 FUEL"
  ]).solveFor(oneFuel) == Quantity(165, "ORE"));
}

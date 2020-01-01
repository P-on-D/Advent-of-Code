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

    return sumOf(
      solution
        .sort!"a.of < b.of"
        .chunkBy!"a.of == b.of"
        .map!(c => sumOf(c.array))
        .map!(req => solveOne(req))
        .array.join
    );
  }
}

auto withReactions(R)(R reactions) {
  import std.conv, std.regex;

  // match order is;
  //   0: all
  //   1: 1st requirement, 2: unit, 3: symbol
  //   4-6: 2nd requirement if present, and so on
  // $-3: output, $-2: unit, $-1: symbol
  auto rxReaction = regex(r"^((\d+) (\w+))(, (\d+) (\w+))* => ((\d+) (\w+))");

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
      auto quantities = matches.chunks(3).filter!(ch => ch.front.length).map!(ch => toQty(ch)).array;
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
    "3 ORE => 17 FUEL"
  ]).solveFor(Quantity(5, "FUEL")) == Quantity(3, "ORE"));

  assert(withReactions([
    "1 ORE => 1 WISH"
  , "1 WISH => 1 FUEL"
  ]).solveFor(Quantity(1, "FUEL")) == Quantity(1, "ORE"));

  assert(withReactions([
    "1 ORE => 1 CHORE"
  , "1 CHORE => 1 WISH"
  , "2 WISH => 1 FISH"
  , "2 FISH => 1 DISH"
  , "2 DISH => 1 DAMAGE"
  , "4 DAMAGE => 1 CRUEL"
  , "2 CRUEL => 1 FUEL"
  ]).solveFor(Quantity(1, "FUEL")) == Quantity(64, "ORE"));

  assert(withReactions([
    "10 ORE => 10 A"
  , "1 ORE => 1 B"
  , "7 A, 1 B => 1 C"
  , "7 A, 1 C => 1 D"
  , "7 A, 1 D => 1 E"
  , "7 A, 1 E => 1 FUEL"
  ]).solveFor(Quantity(1, "FUEL")) == Quantity(31, "ORE"));
}

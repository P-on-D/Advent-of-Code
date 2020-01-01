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

    Quantity sumOf(Quantity[] sameOf) {
      Symbol of = sameOf.front.of;
      return Quantity(sameOf.map!"a.units".sum, of);
    }

    while(solution != previousSolution) {
      previousSolution = solution;
      solution = solution
        .map!(req => isBase(req.of) ? [req] : solveOne(req))
        .array.join
        .sort!"a.of < b.of"
        .chunkBy!"a.of == b.of"
        .map!(c => sumOf(c.array))
        .array;
    }

    solution = solution
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

  assert(withReactions([
    "157 ORE => 5 NZVS"
  , "165 ORE => 6 DCFZ"
  , "44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL"
  , "12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ"
  , "179 ORE => 7 PSHF"
  , "177 ORE => 5 HKGWZ"
  , "7 DCFZ, 7 PSHF => 2 XJWVT"
  , "165 ORE => 2 GPVTF"
  , "3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT"
  ]).solveFor(oneFuel) == Quantity(13312, "ORE"));

  assert(withReactions([
    "2 VPVL, 7 FWMGM, 2 CXFTF, 11 MNCFX => 1 STKFG"
  , "17 NVRVD, 3 JNWZP => 8 VPVL"
  , "53 STKFG, 6 MNCFX, 46 VJHF, 81 HVMC, 68 CXFTF, 25 GNMV => 1 FUEL"
  , "22 VJHF, 37 MNCFX => 5 FWMGM"
  , "139 ORE => 4 NVRVD"
  , "144 ORE => 7 JNWZP"
  , "5 MNCFX, 7 RFSQX, 2 FWMGM, 2 VPVL, 19 CXFTF => 3 HVMC"
  , "5 VJHF, 7 MNCFX, 9 VPVL, 37 CXFTF => 6 GNMV"
  , "145 ORE => 6 MNCFX"
  , "1 NVRVD => 8 CXFTF"
  , "1 VJHF, 6 MNCFX => 4 RFSQX"
  , "176 ORE => 6 VJHF"
  ]).solveFor(oneFuel) == Quantity(180697, "ORE"));

  assert(withReactions([
    "171 ORE => 8 CNZTR"
  , "7 ZLQW, 3 BMBT, 9 XCVML, 26 XMNCP, 1 WPTQ, 2 MZWV, 1 RJRHP => 4 PLWSL"
  , "114 ORE => 4 BHXH"
  , "14 VRPVC => 6 BMBT"
  , "6 BHXH, 18 KTJDG, 12 WPTQ, 7 PLWSL, 31 FHTLT, 37 ZDVW => 1 FUEL"
  , "6 WPTQ, 2 BMBT, 8 ZLQW, 18 KTJDG, 1 XMNCP, 6 MZWV, 1 RJRHP => 6 FHTLT"
  , "15 XDBXC, 2 LTCX, 1 VRPVC => 6 ZLQW"
  , "13 WPTQ, 10 LTCX, 3 RJRHP, 14 XMNCP, 2 MZWV, 1 ZLQW => 1 ZDVW"
  , "5 BMBT => 4 WPTQ"
  , "189 ORE => 9 KTJDG"
  , "1 MZWV, 17 XDBXC, 3 XCVML => 2 XMNCP"
  , "12 VRPVC, 27 CNZTR => 2 XDBXC"
  , "15 KTJDG, 12 BHXH => 5 XCVML"
  , "3 BHXH, 2 VRPVC => 7 MZWV"
  , "121 ORE => 7 VRPVC"
  , "7 XCVML => 6 RJRHP"
  , "5 BHXH, 4 VRPVC => 5 LTCX"
  ]).solveFor(oneFuel) == Quantity(2210736, "ORE"));
}

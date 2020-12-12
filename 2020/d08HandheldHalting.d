// Advent of Code 2020 https://adventofcode.com/2020/day/8
// Day 8: Handheld Halting

enum Op { Nop, Acc, Jmp };
struct Instr { Op op; int arg; }

Instr parseInstruction(string line) {
  import std.array : split;
  import std.conv : to;
  import std.string : capitalize;

  auto parts = line.split(' ');

  return Instr(
    parts[0].capitalize.to!Op,
    parts[1].to!int
  );
}

unittest {
  import std.algorithm : equal, map;

  auto input = [
    "nop +0",
    "acc +1",
    "jmp +4",
    "acc +3",
    "jmp -3",
    "acc -99",
    "acc +1",
    "jmp -4",
    "acc +6"
  ];

  assert(input.map!parseInstruction.equal([
    Instr(Op.Nop, 0),
    Instr(Op.Acc, 1),
    Instr(Op.Jmp, 4),
    Instr(Op.Acc, 3),
    Instr(Op.Jmp, -3),
    Instr(Op.Acc, -99),
    Instr(Op.Acc, 1),
    Instr(Op.Jmp, -4),
    Instr(Op.Acc, 6)
  ]));
}

void main() {}

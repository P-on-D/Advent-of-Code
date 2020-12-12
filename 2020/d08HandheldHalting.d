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

auto haltingExecutor(Instr [] program) {
  int PC, acc;
  bool[] visited = new bool[program.length];

  while(!visited[PC]) {
    visited[PC] = true;

    final switch (program[PC].op) {
      case Op.Nop: PC += 1; break;
      case Op.Acc: acc += program[PC].arg; PC += 1; break;
      case Op.Jmp: PC += program[PC].arg; break;
    }
  }

  return acc;
}

unittest {
  import std.algorithm : equal, map;
  import std.array : array;

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

  assert(input.map!parseInstruction.array.haltingExecutor == 5);
}

void main() {
  import std.algorithm : map, splitter;
  import std.array : array;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto program = data.map!parseInstruction.array;
  program.haltingExecutor.writeln;
}

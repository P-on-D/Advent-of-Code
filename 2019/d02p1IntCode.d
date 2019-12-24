int[] memory;

alias Addr = int;

enum Opcode { Add = 1, Mul = 2, End = 99 }

struct Instr { Opcode op; Addr ld1, ld2, st; }

Addr parse(Addr PC, out Instr instr) {
  import std.conv;

  instr.op = to!Opcode(memory[PC]);
  if (instr.op != Opcode.End) {
    instr.ld1 = memory[PC+1];
    instr.ld2 = memory[PC+2];
    instr.st = memory[PC+3];
  }
  return PC + 4;
}

bool execute(Instr instr) {
  auto v1 = memory[instr.ld1];
  auto v2 = memory[instr.ld2];

  final switch (instr.op) {
    case Opcode.Add: memory[instr.st] = v1 + v2; return true;
    case Opcode.Mul: memory[instr.st] = v1 * v2; return true;
    case Opcode.End: return false;
  }
}

bool trace(Instr instr) {
  import std.stdio;
  writef("%s %s=%s %s=%s", instr, instr.ld1, memory[instr.ld1], instr.ld2, memory[instr.ld2]);
  auto x = execute(instr);
  writefln(" %s=%s", instr.st, memory[instr.st]);
  return x;
}

unittest {
  memory = [1,9,10,3,2,3,11,0,99,30,40,50];

  Instr i;

  assert(parse(0, i) == 4);
  assert(i == Instr(Opcode.Add, 9, 10, 3));

  assert(parse(4, i) == 8);
  assert(i == Instr(Opcode.Mul, 3, 11, 0));

  assert(parse(8, i) == 12);
  assert(i.op == Opcode.End);

  Addr PC;

  PC = parse(PC, i);
  assert(execute(i));
  assert(memory == [1,9,10,70,2,3,11,0,99,30,40,50]);

  PC = parse(PC, i);
  assert(execute(i));
  assert(memory == [3500,9,10,70,2,3,11,0,99,30,40,50]);

  PC = parse(PC, i);
  assert(!execute(i));
  assert(memory == [3500,9,10,70,2,3,11,0,99,30,40,50]);

  memory = [1, 0, 0, 0, 99];
  parse(0, i);
  assert(execute(i));
  assert(memory == [2, 0, 0, 0, 99]);

  memory = [2,3,0,3,99];
  parse(0, i);
  assert(execute(i));
  assert(memory == [2,3,0,6,99]);

  memory = [2,4,4,5,99,0];
  parse(0, i);
  assert(execute(i));
  assert(memory == [2,4,4,5,99,9801]);

  memory = [1,1,1,4,99,5,6,0,99];
  parse(0, i);
  assert(execute(i));
  parse(4, i);
  assert(execute(i));
  parse(8, i);
  assert(!execute(i));
  assert(memory == [30,1,1,4,2,5,6,0,99]);
} version (unittest) {} else {

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  memory = stdin.readln.split(',').map!(to!int).array;

  memory[1] = 12;
  memory[2] = 2;

  Addr PC;
  Instr i;

  do {
    PC = parse(PC, i);
  } while(trace(i));

  memory[0].writeln;
}

}

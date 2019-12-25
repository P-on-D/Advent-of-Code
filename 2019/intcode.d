module intcode;

struct IntCode {
  int[] memory;
  int[] input;
  int[] output;

  alias Addr = int;

  enum Opcode { Add = 1, Mul = 2, In = 3, Out = 4, End = 99 }

  struct Instr { Opcode op; Addr ld1, ld2, st; }

  Addr parse(Addr PC, out Instr instr) {
    import std.conv;

    instr.op = to!Opcode(memory[PC]);
    final switch (instr.op) {
      case Opcode.Add:
      case Opcode.Mul:
        instr.ld1 = memory[PC+1];
        instr.ld2 = memory[PC+2];
        instr.st = memory[PC+3];
        return PC + 4;
      case Opcode.In:
      case Opcode.Out:
        instr.st = memory[PC+1];
        return PC + 2;
      case Opcode.End:
        return PC;
    }
  }

  bool execute(Instr instr) {
    import std.range;

    auto v1 = memory[instr.ld1];
    auto v2 = memory[instr.ld2];

    final switch (instr.op) {
      case Opcode.Add: memory[instr.st] = v1 + v2; return true;
      case Opcode.Mul: memory[instr.st] = v1 * v2; return true;
      case Opcode.In: memory[instr.st] = input.front; input.popFront; return true;
      case Opcode.Out: output ~= memory[instr.st]; return true;
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

  auto run(int[] input = []) {
    this.input = input;
    output = [];

    Addr PC;
    Instr i;

    do {
      PC = parse(PC, i);
    } while(execute(i));

    return output;
  }

  auto runWithTrace(int[] input = []) {
    this.input = input;
    output = [];

    Addr PC;
    Instr i;

    do {
      PC = parse(PC, i);
    } while(trace(i));

    return output;
  }
}

unittest {
  IntCode ic = IntCode([1,9,10,3,2,3,11,0,99,30,40,50]);
  ic.run();
  assert(ic.memory == [3500,9,10,70,2,3,11,0,99,30,40,50]);

  ic.memory = [1, 0, 0, 0, 99];
  ic.run();
  assert(ic.memory == [2, 0, 0, 0, 99]);

  ic.memory = [2,3,0,3,99];
  ic.run();
  assert(ic.memory == [2,3,0,6,99]);

  ic.memory = [2,4,4,5,99,0];
  ic.run();
  assert(ic.memory == [2,4,4,5,99,9801]);

  ic.memory = [1,1,1,4,99,5,6,0,99];
  ic.run();
  assert(ic.memory == [30,1,1,4,2,5,6,0,99]);

  ic.memory = [3,0,4,0,99];
  assert(ic.run([1]) == [1]);
}

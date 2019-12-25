module intcode;

struct IntCode {
  int[] memory;
  int[] input;
  int[] output;

  alias Addr = int;

  enum Opcode { Add = 1, Mul = 2, In = 3, Out = 4, JT = 5, JF = 6, Lt = 7, Eq = 8, End = 99 }

  struct Instr { Opcode op; Addr ld1, ld2, st; }

  Addr parse(Addr PC, out Instr instr) {
    import std.conv;

    auto opcode = memory[PC];
    bool p1imm = (opcode / 100) % 10 == 1;
    bool p2imm = (opcode / 1000) % 10 == 1;

    int v(int n, bool imm) {
      return imm ? memory[PC+n] : memory[memory[PC+n]];
    }

    instr.op = to!Opcode(opcode % 100);
    final switch (instr.op) {
      case Opcode.JT:
        return v(1, p1imm) != 0
          ? v(2, p2imm)
          : PC + 3;
      case Opcode.JF:
        return v(1, p1imm) == 0
          ? v(2, p2imm)
          : PC + 3;
      case Opcode.Add:
      case Opcode.Mul:
      case Opcode.Lt:
      case Opcode.Eq:
        instr.ld1 = v(1, p1imm);
        instr.ld2 = v(2, p2imm);
        instr.st = memory[PC+3];
        return PC + 4;
      case Opcode.In:
        instr.st = memory[PC+1];
        return PC + 2;
      case Opcode.Out:
        instr.st = v(1, p1imm);
        return PC + 2;
      case Opcode.End:
        return PC;
    }
  }

  bool execute(Instr instr) {
    import std.range;

    final switch (instr.op) {
      case Opcode.Add: memory[instr.st] = instr.ld1 + instr.ld2; return true;
      case Opcode.Mul: memory[instr.st] = instr.ld1 * instr.ld2; return true;
      case Opcode.Lt: memory[instr.st] = instr.ld1 < instr.ld2; return true;
      case Opcode.Eq: memory[instr.st] = instr.ld1 == instr.ld2; return true;
      case Opcode.In: memory[instr.st] = input.front; input.popFront; return true;
      case Opcode.JT: return true;
      case Opcode.JF: return true;
      case Opcode.Out: output ~= instr.st; return true;
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

  ic.memory = [1002,4,3,4,33];
  ic.run();
  assert(ic.memory == [1002,4,3,4,99]);

  ic.memory = [1101,100,-1,4,0];
  ic.run();
  assert(ic.memory == [1101,100,-1,4,99]);

  ic.memory = [104,42,99];
  assert(ic.run == [42]);

  assert(IntCode([3,9,8,9,10,9,4,9,99,-1,8]).run([8]) == [1]);
  assert(IntCode([3,9,8,9,10,9,4,9,99,-1,8]).run([7]) == [0]);

  assert(IntCode([3,9,7,9,10,9,4,9,99,-1,8]).run([8]) == [0]);
  assert(IntCode([3,9,7,9,10,9,4,9,99,-1,8]).run([7]) == [1]);

  assert(IntCode([3,3,1108,-1,8,3,4,3,99]).run([8]) == [1]);
  assert(IntCode([3,3,1108,-1,8,3,4,3,99]).run([7]) == [0]);

  assert(IntCode([3,3,1107,-1,8,3,4,3,99]).run([8]) == [0]);
  assert(IntCode([3,3,1107,-1,8,3,4,3,99]).run([7]) == [1]);

  assert(IntCode([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]).run([0]) == [0]);
  assert(IntCode([3,12,6,12,15,1,13,14,13,4,13,99,-1,0,1,9]).run([-1]) == [1]);

  assert(IntCode([3,3,1105,-1,9,1101,0,0,12,4,12,99,1]).run([0]) == [0]);
  assert(IntCode([3,3,1105,-1,9,1101,0,0,12,4,12,99,1]).run([-1]) == [1]);

  auto largerExample = [3,21,1008,21,8,20,1005,20,22,107,8,21,20,1006,20,31,
    1106,0,36,98,0,0,1002,21,125,20,4,20,1105,1,46,104,
    999,1105,1,46,1101,1000,1,20,4,20,1105,1,46,98,99];
  assert(IntCode(largerExample).run([6]) == [999]);
  assert(IntCode(largerExample).run([8]) == [1000]);
  assert(IntCode(largerExample).run([10]) == [1001]);
}

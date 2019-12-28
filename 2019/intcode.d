module intcode;

struct IntCode {
  int[] memory;
  int[] input;
  int[] output;

  alias Addr = int;

  Addr PC;
  bool halted = true;
  bool feedback = false;

  enum Opcode { Add = 1, Mul = 2, In = 3, Out = 4, JT = 5, JF = 6, Lt = 7, Eq = 8, End = 99 }

  struct Instr { Opcode op; Addr ld1, ld2, st; }

  bool execute() {
    import std.conv, std.range;

    auto opcode = memory[PC];
    bool p1imm = (opcode / 100) % 10 == 1;
    bool p2imm = (opcode / 1000) % 10 == 1;

    int v(int n, bool imm) {
      return imm ? memory[n] : memory[memory[n]];
    }

    Instr instr;

    void ld() {
      instr.ld1 = v(PC+1, p1imm);
      instr.ld2 = v(PC+2, p2imm);
    }

    instr.op = to!Opcode(opcode % 100);

    final switch (instr.op) {
      case Opcode.JT:  ld(); PC = (instr.ld1 != 0) ? instr.ld2 : (PC + 3); return true;
      case Opcode.JF:  ld(); PC = (instr.ld1 == 0) ? instr.ld2 : (PC + 3); return true;
      case Opcode.Add: ld(); memory[memory[PC+3]] = instr.ld1 + instr.ld2; PC = PC + 4; return true;
      case Opcode.Mul: ld(); memory[memory[PC+3]] = instr.ld1 * instr.ld2; PC = PC + 4; return true;
      case Opcode.Lt:  ld(); memory[memory[PC+3]] = instr.ld1 < instr.ld2; PC = PC + 4; return true;
      case Opcode.Eq:  ld(); memory[memory[PC+3]] = instr.ld1 == instr.ld2; PC = PC + 4; return true;
      case Opcode.In:  if (input.empty) return false;
                       memory[memory[PC+1]] = input.front; input.popFront; PC = PC + 2; return true;
      case Opcode.Out: output ~= v(PC+1, p1imm); PC = PC + 2; return !feedback;
      case Opcode.End: halted = true; return false;
    }
  }

  auto run(int[] input = []) {
    this.input = input;
    output = [];
    PC = 0;
    halted = false;

    while(execute()) {}

    return output;
  }

  auto cont(int[] input = []) {
    this.input = input;
    if (halted) return output;
    if (feedback) output = [];

    while(execute()) {}

    return output;
  }

  auto runInFeedback(int[] input = []) {
    feedback = true;
    return run(input);
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

  auto outputOnePlusInputFiveTimes = [
    3, 16, 101, 1, 16, 16, 4, 16, 101, -1, 16+1, 16+1, 1005, 16+1, 0, 99, 0, 5
  ];
  ic = IntCode(outputOnePlusInputFiveTimes.dup);
  assert(ic.run([1, 2, 3, 4, 5]) == [2, 3, 4, 5, 6]);

  ic = IntCode(outputOnePlusInputFiveTimes.dup);
  ic.run();
  assert(!ic.halted);

  assert(ic.cont([1]) == [2]);
  assert(ic.cont([2]) == [2, 3]);
  ic.output = [];
  assert(ic.cont([3]) == [4]);
  assert(ic.cont([4, 5]) == [4, 5, 6]);
  assert(ic.halted);

  ic = IntCode(outputOnePlusInputFiveTimes.dup);
  auto feedback = ic.runInFeedback([1]);

  do {
    feedback = ic.cont(feedback);
    ic.cont();
  } while(!ic.halted);

  assert(feedback == [6]);
}

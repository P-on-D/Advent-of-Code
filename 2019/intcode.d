module intcode;

alias IntCode = IntCodeT!int;
alias LongCode = IntCodeT!long;

struct IntCodeT(T) {
  alias Word = T;

  this(Word[] program, uint capacity = 65536) {
    memory = program.dup;
    memory.length = capacity;
  }

  Word[] memory;
  Word[] input;
  Word[] output;

  alias Addr = Word;

  Addr PC, RB;
  bool halted = true;
  bool feedback = false;

  struct Opcode {
    enum {
      Add = 1, Mul
    , In = 3, Out
    , JT = 5, JF
    , Lt = 7, Eq
    , Rel = 9
    , End = 99
    }
  }

  struct Mode {
    enum { Pos, Imm, Rel }
  }

  bool execute() {
    import std.conv, std.range;

    auto opcode = memory[PC];
    auto m1 = (opcode / 100) % 10
       , m2 = (opcode / 1000) % 10
       , m3 = (opcode / 10000) % 10;

    Word ld(Addr n)() if (n >= 1 && n <= 3) {
      auto param = memory[PC+n];
      auto mode = mixin( "m" ~ to!string(n) );

      final switch (mode) with (Mode) {
        case Pos: return memory[param];
        case Imm: return param;
        case Rel: return memory[RB+param];
      }
    }

    void st(Addr n)(Word v) if (n >= 1 && n <= 3) {
      auto param = memory[PC+n];
      auto mode = mixin( "m" ~ to!string(n) );

      final switch (mode) with (Mode) {
        case Pos: memory[param] = v; return;
        case Imm: return;
        case Rel: memory[RB+param] = v; return;
      }
    }

    auto op = opcode % 100;

    final switch (op) with (Opcode) {
      case JT:  PC = (ld!1 != 0) ? ld!2 : (PC + 3); return true;
      case JF:  PC = (ld!1 == 0) ? ld!2 : (PC + 3); return true;
      case Add: st!3(ld!1 + ld!2); PC = PC + 4; return true;
      case Mul: st!3(ld!1 * ld!2); PC = PC + 4; return true;
      case Lt:  st!3(ld!1 < ld!2); PC = PC + 4; return true;
      case Eq:  st!3(ld!1 == ld!2); PC = PC + 4; return true;
      case In:  if (input.empty) return false;
                st!1(input.front); input.popFront; PC = PC + 2; return true;
      case Out: output ~= ld!1; PC = PC + 2; return !feedback;
      case Rel: RB += ld!1; PC = PC + 2; return true;
      case End: halted = true; return false;
    }
  }

  auto run(Word[] input = []) {
    this.input = input;
    output = [];
    PC = 0;
    RB = 0;
    halted = false;

    while(execute()) {}

    return output;
  }

  auto cont(Word[] input = []) {
    this.input = input;
    if (halted) return output;
    if (feedback) output = [];

    while(execute()) {}

    return output;
  }

  auto runInFeedback(Word[] input = []) {
    feedback = true;
    return run(input);
  }
}

unittest {
  IntCode ic = IntCode([1,9,10,3,2,3,11,0,99,30,40,50]);
  ic.run();
  assert(ic.memory[0..12] == [3500,9,10,70,2,3,11,0,99,30,40,50]);

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

  auto quine = [109,1,204,-1,1001,100,1,100,1008,100,16,101,1006,101,0,99];
  ic = IntCode(quine.dup);
  assert(ic.run() == quine);

  assert(LongCode([1102,34915192,34915192,7,4,7,99,0]).run()[0] / 1000_0000_0000_0000 > 0);
  assert(LongCode([104,1125899906842624,99]).run() == [1125899906842624]);
}

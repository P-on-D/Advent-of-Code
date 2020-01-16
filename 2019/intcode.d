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

  struct Access {
    enum { None, Load, Store }
  }

  void execute() {
    import std.array, std.conv, std.range;

    string cases(string op, uint loads, uint store, string executor) {
      import std.format;

      auto accs = [Access.None, Access.None, Access.None];
      auto modes = [[0], [0], [0]];

      string generate(int a, int m, int arg) {
        if (a == Access.None) return "";

        string p = "memory[PC+%d]".format(arg);
        string access;

        if (a == Access.Load) {
          switch (m) {
            case Mode.Pos: access = "memory["~p~"]"; break;
            case Mode.Imm: access = p; break;
            case Mode.Rel: access = "memory[RB+"~p~"]"; break;
            default: break;
          }
        } else {
          switch (m) {
            case Mode.Pos: access = p; break;
            case Mode.Rel: access = "RB+"~p; break;
            default: break;
          }
        }

        return "auto a%d = %s;".format(arg, access);
      }

      if (store) {
        accs[store-1] = Access.Store;
        modes[store-1] = [0, 2];
      }

      if (loads >= 1) {
        accs[0] = Access.Load;
        modes[0] = [0, 1, 2];
      }

      if(loads == 2) {
        accs[1] = Access.Load;
        modes[1] = [0, 1, 2];
      }

      string output;

      foreach(m1; modes[0]) {
        foreach(m2; modes[1]) {
          foreach(m3; modes[2]) {
            auto offset = 10000 * m3 + 1000 * m2 + 100 * m1;

            output ~= "case %d + %s:".format(offset, op);
            output ~= generate(accs[0], m1, 1);
            output ~= generate(accs[1], m2, 2);
            output ~= generate(accs[2], m3, 3);
            output ~= executor;
          }
        }
      }

      return output;
    }

  AndCarryOn:
    auto opcode = memory[PC];

    switch (opcode) with (Opcode) {
      case End: halted = true; return;

      mixin(cases( "JT",  2, 0, q{ PC = (a1 != 0) ? a2 : (PC + 3); goto AndCarryOn; } ));
      mixin(cases( "JF",  2, 0, q{ PC = (a1 == 0) ? a2 : (PC + 3); goto AndCarryOn; } ));

      mixin(cases( "Add", 2, 3, q{ memory[a3] = (a1 + a2); PC = PC + 4; goto AndCarryOn; } ));
      mixin(cases( "Mul", 2, 3, q{ memory[a3] = (a1 * a2); PC = PC + 4; goto AndCarryOn; } ));
      mixin(cases( "Lt",  2, 3, q{ memory[a3] = (a1 < a2); PC = PC + 4; goto AndCarryOn; } ));
      mixin(cases( "Eq",  2, 3, q{ memory[a3] = (a1 == a2); PC = PC + 4; goto AndCarryOn; } ));

      mixin(cases( "In",  0, 1, q{ if (input.empty) return;
                                   memory[a1] = input.front; input.popFront; PC = PC + 2; goto AndCarryOn; } ));

      mixin(cases( "Out", 1, 0, q{ output ~= a1; PC = PC + 2;
                                   if (feedback) return; else goto AndCarryOn; } ));

      mixin(cases( "Rel", 1, 0, q{ RB += a1; PC = PC + 2; goto AndCarryOn; } ));

      default:
        PC = PC + 1;
        import std.stdio;
        writefln("Opcode %s at %s not understood", opcode, PC);
        return;
    }
  }

  auto run(Word[] input = []) {
    this.input = input;
    output = [];
    PC = 0;
    RB = 0;
    halted = false;

    execute;

    return output;
  }

  auto cont(Word[] input = []) {
    this.input = input;
    if (halted) return output;
    if (feedback) output = [];

    execute;

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

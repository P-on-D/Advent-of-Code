auto thrusterSignal(int[] program, int[] phases) {
  import intcode;
  int input;

  foreach(phase; phases) {
    input = IntCode(program.dup).run([phase, input])[0];
  }

  return input;
}

auto maxThrusterSignal(int[] program) {
  import std.algorithm, std.range, std.typecons;

  int maxSignal;
  int[] maxPhases;

  foreach(phases; iota(0, 5).permutations) {
    int signal = thrusterSignal(program, phases.array);
    if (signal > maxSignal) {
      maxSignal = signal;
      maxPhases = phases.array;
    }
  }

  return tuple(maxSignal, maxPhases);
}

unittest {
  import std.algorithm, std.range, std.typecons;

  assert(iota(0, 5).permutations.count == 5 * 4 * 3 * 2);

  assert(
    thrusterSignal(
      [3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0]
    , [4,3,2,1,0]
    ) == 43210
  );
  assert(
    thrusterSignal(
      [3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0]
    , [0,1,2,3,4]
    ) == 54321
  );
  assert(
    thrusterSignal(
      [3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0]
    , [1,0,4,3,2]
    ) == 65210
  );

  assert(
    maxThrusterSignal([3,15,3,16,1002,16,10,16,1,16,15,15,4,15,99,0,0])
      == tuple(43210, [4,3,2,1,0])
  );
  assert(
    maxThrusterSignal([3,23,3,24,1002,24,10,24,1002,23,-1,23,101,5,23,23,1,24,23,23,4,23,99,0,0])
      == tuple(54321, [0,1,2,3,4])
  );
  assert(
    maxThrusterSignal([3,31,3,32,1002,32,10,32,1001,31,-2,31,1007,31,0,33,1002,33,7,33,1,33,31,31,1,32,31,31,4,31,99,0,0,0])
      == tuple(65210, [1,0,4,3,2])
  );
}
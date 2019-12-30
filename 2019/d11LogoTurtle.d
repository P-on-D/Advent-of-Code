struct Pt { int x, y; }

struct Turtle(T) {
  T brain;

  int dir;
  Pt pos;

  this(T program) {
    brain = program;
    brain.runInFeedback;
  }

  auto halted() { return brain.halted; }

  auto turn(int input) {
    dir = (dir + (input ? 1 : -1)) & 3;
    final switch (dir) {
      case 0: pos.y--; break;
      case 1: pos.x++; break;
      case 2: pos.y++; break;
      case 3: pos.x--; break;
    }
    return pos;
  }
}

auto loadTurtle() {
  import intcode, std.algorithm, std.array, std.conv, std.stdio;

  return Turtle!LongCode(LongCode(stdin.readln.split(',').map!(to!long).array));
}

unittest {
  auto turtle = loadTurtle();
  assert(!turtle.halted);
  assert(turtle.turn(0) == Pt(-1,0));
  assert(turtle.turn(0) == Pt(-1,1));
  assert(turtle.turn(0) == Pt(0,1));
  assert(turtle.turn(0) == Pt(0,0));
  assert(turtle.turn(1) == Pt(1,0));
  assert(turtle.turn(0) == Pt(1,-1));
  assert(turtle.turn(0) == Pt(0,-1));
}

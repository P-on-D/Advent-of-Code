import std.algorithm;

struct Pt { int x, y; }

struct Turtle(T) {
  T brain;

  int dir;
  Pt pos;

  this(T program) {
    brain = program;
    brain.run;
  }

  auto halted() { return brain.halted; }

  auto reset() {
    dir = 0;
    pos = Pt(0,0);
    brain.run;
  }

  auto turn(T.Word input) {
    dir = (dir + (input ? 1 : -1)) & 3;
    final switch (dir) {
      case 0: pos.y--; break;
      case 1: pos.x++; break;
      case 2: pos.y++; break;
      case 3: pos.x--; break;
    }
    return pos;
  }

  auto step(T.Word input) {
    auto output = brain.cont([input]);
    brain.output = [];
    return output;
  }
}

auto loadTurtle(long[] opcodes) {
  import intcode;

  return Turtle!LongCode(LongCode(opcodes));
}

auto runTurtle(T)(T turtle) {
  long[Pt] grid;
  return runTurtle(turtle, grid);
}

auto runTurtle(T)(T turtle, long[Pt] grid) {
  while(!turtle.halted) {
    auto input = grid.get(turtle.pos, 0);
    auto output = turtle.step(input);

    grid[turtle.pos] = output[0];
    turtle.turn(output[1]);
  }

  return grid;
}

auto assembler(string code) {
  long[] opcodes;
  long[string] labels;

  foreach(pass; 0 .. 2) {
    import std.array, std.conv, std.range, std.string;

    auto lineno = 0;
    opcodes = [];

    foreach(line; code.split("\n").map!strip.filter!"a.length") {
      ++lineno;

      if(line.endsWith(":")) {
        if (pass == 0) labels[line[0..$-1]] = opcodes.length;
      } else {
        auto op = line.findSplit(" ");
        auto opcode = op[0];
        auto args = op[2].split(",").map!strip;

        auto parseArgs(T)(long opcode, T args) {
          auto parsed = [opcode];
          auto modeMul = 100;

          foreach(arg; args) {
            if (arg.startsWith("#")) {
              opcode += 1 * modeMul;
              arg = arg[1..$];
            }

            if (arg.isNumeric) {
              parsed ~= to!long(arg);
            } else {
              if (pass == 1) {
                parsed ~= labels[arg];
              } else {
                parsed ~= -999;
              }
            }

            modeMul *= 10;
          }

          parsed[0] = opcode;
          return parsed;
        }

        switch(opcode) {
          case "In":
            opcodes ~= parseArgs(3, args[0..1]);
            break;

          case "Out":
            opcodes ~= parseArgs(4, args[0..1]);
            break;

          case "JT":
            opcodes ~= parseArgs(5, args[0..2]);
            break;

          case "JF":
            opcodes ~= parseArgs(6, args[0..2]);
            break;

          case "End":
            opcodes ~= 99;
            break;

          case "Var":
            opcodes ~= to!int(args[0]);
            break;

          default:
            assert(false, "On line %s, WTF is %s?".format(lineno, opcode));
            break;
        }
      }
    }
  }

  return opcodes;
}

auto plot(long[Pt] grid) {
  char[][] output;

  auto minY = grid.keys.minElement!"a.y".y
     , minX = grid.keys.minElement!"a.x".x
     , maxY = grid.keys.maxElement!"a.y".y
     , maxX = grid.keys.maxElement!"a.x".x;

  foreach(y; minY .. maxY + 1) {
    char[] line;

    foreach(x; minX .. maxX + 1) {
      if (Pt(x, y) in grid) {
        line ~= grid[Pt(x, y)] ? '#' : '.';
      } else {
        line ~= ' ';
      }
    }

    output ~= line;
  }

  return output;
}

unittest {
  auto turtle = loadTurtle([3,3,99,0]);
  assert(!turtle.halted);
  assert(turtle.turn(0) == Pt(-1,0));
  assert(turtle.turn(0) == Pt(-1,1));
  assert(turtle.turn(0) == Pt(0,1));
  assert(turtle.turn(0) == Pt(0,0));
  assert(turtle.turn(1) == Pt(1,0));
  assert(turtle.turn(0) == Pt(1,-1));
  assert(turtle.turn(0) == Pt(0,-1));

  auto exampleCode = assembler("
    In x
    JT x, #Error
    Out #1
    Out #0
    In x
    JT x, #Error
    Out #0
    Out #0
    In x
    Out #1
    Out #0
    In x
    Out #1
    Out #0
    In x
    JF x, #Error
    Out #0
    Out #1
    In x
    Out #1
    Out #0
    In x
    Out #1
    Out #0
  Error:
    End
  x:
    Var 0
  ");

  turtle = loadTurtle(exampleCode);
  assert(turtle.step(0) == [1, 0]);
  assert(turtle.step(0) == [0, 0]);
  assert(turtle.step(0) == [1, 0]);
  assert(turtle.step(0) == [1, 0]);
  assert(turtle.step(1) == [0, 1]);
  assert(turtle.step(0) == [1, 0]);
  assert(turtle.step(0) == [1, 0]);
  assert(turtle.halted);

  turtle.reset;
  assert(turtle.step(0) == [1, 0]);

  assert(exampleCode.loadTurtle.runTurtle.length == 6);
  assert(exampleCode.loadTurtle.runTurtle.plot == [
    "  #"
  , "..#"
  , "## "
  ]);
} version (unittest) {} else {

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  auto turtle = stdin.readln.split(',').map!(to!long).array
    .loadTurtle;

  long[Pt] grid;

  turtle
    .runTurtle(grid)
    .length
    .writeln;

  turtle.reset;
  grid = [Pt(0,0): 1];

  turtle.runTurtle(grid).plot.each!writeln;
}

}

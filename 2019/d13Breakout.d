import std.algorithm;

struct Pt { int x, y; }

auto plot(T)(T[Pt] grid, char[T] lookup) {
  char[][] output;

  auto minY = grid.keys.minElement!"a.y".y
     , minX = grid.keys.minElement!"a.x".x
     , maxY = grid.keys.maxElement!"a.y".y
     , maxX = grid.keys.maxElement!"a.x".x;

  foreach(y; minY .. maxY + 1) {
    char[] line;

    foreach(x; minX .. maxX + 1) {
      if (Pt(x, y) in grid) {
        line ~= lookup.get(grid[Pt(x, y)], grid[Pt(x,y)]);
      } else {
        line ~= ' ';
      }
    }

    output ~= line;
  }

  return output;
}

void main() {
  import intcode, std.array, std.conv, std.stdio;

  auto breakoutProgram = stdin.readln.split(',').map!(to!long).array;

  auto breakout = LongCode(breakoutProgram);

  auto x = breakout.runInFeedback;

  ubyte[Pt] grid;
  while(!breakout.halted) {
    auto y = breakout.cont;
    auto t = breakout.cont;
    grid[Pt(cast(int)x[0], cast(int)y[0])] = cast(ubyte)t[0];
    x = breakout.cont;
  }

  char[ubyte] symbols = [0: ' ', 1: '#', 2: '=', 3: '_', 4: '@'];

  "\x1B[2J".writeln;

  grid.plot(symbols).each!writeln;
  grid.values.count!"a == 2".writeln;

  breakoutProgram[0] = 2;
  breakout = LongCode(breakoutProgram);
  auto input = 0;
  long score = 0;
  Pt ball, paddle;
  grid.clear;

  x = breakout.runInFeedback([input]);
  while(!breakout.halted) {
    auto y = breakout.cont;
    auto t = breakout.cont;
    if (x[0] == -1 && y[0] == 0) {
      score = t[0];
    } else {
      Pt pt = Pt(cast(int)x[0], cast(int)y[0]);
      if (t[0] == 4) ball = pt; else if(t[0] == 3) paddle = pt;
      grid[pt] = cast(ubyte)t[0];
    }

    writeln("\x1B[3;0H", score);
    grid.plot(symbols).each!writeln;

    import std.math;
    input = sgn(ball.x - paddle.x);
    x = breakout.cont([input]);
  }

  writeln("\x1B[3;0H", score);
  grid.plot(symbols).each!writeln;
}

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

  auto breakout = LongCode(stdin.readln.split(',').map!(to!long).array);

  auto x = breakout.runInFeedback;

  ubyte[Pt] grid;
  while(!breakout.halted) {
    auto y = breakout.cont;
    auto t = breakout.cont;
    grid[Pt(cast(int)x[0], cast(int)y[0])] = cast(ubyte)t[0];
    x = breakout.cont;
  }

  grid.plot([0: ' ', 1: '#', 2: '=', 3: '_', 4: '@']).each!writeln;
  grid.values.count!"a == 2".writeln;
}
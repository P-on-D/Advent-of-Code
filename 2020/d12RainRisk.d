// Advent of Code 2020 https://adventofcode.com/2020/day/12
// Day 12: Rain Risk

auto navigate(string[] input) {
  import std.algorithm : each;
  import std.conv : to;
  import std.math : abs;

  int x, y, dir = 90;

  void step(string instr) {
    char action = instr[0];
    uint value = to!uint(instr[1..$]);

    switch(action) {
      default: assert(0);
      case 'N': y -= value; break;
      case 'S': y += value; break;
      case 'E': x += value; break;
      case 'W': x -= value; break;
      case 'L': dir = (dir + (360 - value)) % 360; break;
      case 'R': dir = (dir + value) % 360; break;
      case 'F': {
        switch(dir) {
          default: assert(0);
          case 0:   y -= value; break;
          case 90:  x += value; break;
          case 180: y += value; break;
          case 270: x -= value; break;
        }
        break;
      }
    }
  }

  input.each!step;

  return abs(x) + abs(y);
}

unittest {
  auto input = [
    "F10",
    "N3",
    "F7",
    "R90",
    "F11",
  ];

  assert(input.navigate == 25);
}

void main() {}

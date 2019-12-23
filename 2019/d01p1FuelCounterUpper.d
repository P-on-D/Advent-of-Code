import std.algorithm;

int fuelFor(int mass) {
  int fuel = mass / 3 - 2;
  return fuel <= 0 ? 0 : fuel + fuelFor(fuel);
}

unittest {
  auto input = [12, 14, 1969, 100756];
  auto fuelTotal = input.map!"a / 3 - 2".sum;
  assert(fuelTotal == 2 + 2 + 654 + 33583); // 34241

  assert(fuelFor(14) == 2);
  assert(fuelFor(1969) == 966);
  assert(fuelFor(100756) == 50346);
} version(unittest) {} else {

void main() {
  import std.conv, std.stdio;
  stdin.byLineCopy.map!(to!int).map!fuelFor.sum.writeln;
}

}

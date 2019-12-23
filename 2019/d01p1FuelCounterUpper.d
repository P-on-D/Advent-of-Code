import std.algorithm;

unittest {
  auto input = [12, 14, 1969, 100756];
  auto fuelTotal = input.map!"a / 3 - 2".sum;
  assert(fuelTotal == 2 + 2 + 654 + 33583); // 34241
} version(unittest) {} else {

void main() {
  import std.conv, std.stdio;
  stdin.byLineCopy.map!(to!int).map!"a / 3 - 2".sum.writeln;
}

}

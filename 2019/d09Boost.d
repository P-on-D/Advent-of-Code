import intcode;

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  auto BOOST = stdin.readln.split(',').map!(to!long).array;
  LongCode(BOOST).run([1]).writeln;
  LongCode(BOOST).run([2]).writeln;
}

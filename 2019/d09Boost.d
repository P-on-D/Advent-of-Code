import intcode;

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  auto BOOST = stdin.readln.split(',').map!(to!long).array;
  LongCode(BOOST.dup).run([1]).writeln;
  LongCode(BOOST.dup).run([2]).writeln;
}

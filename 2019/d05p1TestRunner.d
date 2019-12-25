import intcode;

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  auto input = stdin.readln.split(',').map!(to!int).array;
  IntCode(input).run([1]).writeln;
}

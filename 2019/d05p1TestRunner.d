import intcode;

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  auto input = stdin.readln.split(',').map!(to!int).array;
  IntCode(input.dup).run([1]).writeln;
  IntCode(input.dup).run([5]).writeln;
}

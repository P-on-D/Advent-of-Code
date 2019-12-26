import intcode;

void main() {
  import std.algorithm, std.array, std.conv, std.stdio;

  LongCode(stdin.readln.split(',').map!(to!long).array).run([1]).writeln;
}
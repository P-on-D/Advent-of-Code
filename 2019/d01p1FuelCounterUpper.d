unittest {
  import std.algorithm;

  auto input = [12, 14, 1969, 100756];
  auto fuelTotal = input.map!"a / 3 - 2".sum;
  assert(fuelTotal == 2 + 2 + 654 + 33583);
}

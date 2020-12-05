// Advent of Code 2020 https://adventofcode.com/2020/day/1
// Day 1: Report Repair

auto elementsThatSumTo(R, T)(R input, T sumTarget) {
  import std.algorithm : cartesianProduct, filter;
  return cartesianProduct(input, input).filter!(a => a[0] + a[1] == sumTarget).front;
}

unittest {
  auto input = [
    1721,
    979,
    366,
    299,
    675,
    1456
  ];

  auto result = input.elementsThatSumTo(2020);
  assert(result[0] == 1721);
  assert(result[1] == 299);

  // Defend against naïve implementation
  result = [1010, 1721, 299].elementsThatSumTo(2020);
  assert(result[0] == 1721);
  assert(result[1] == 299);
}

void main(string[] args) {
  
}

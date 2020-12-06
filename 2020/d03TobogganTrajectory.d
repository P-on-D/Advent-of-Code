// Advent of Code 2020 https://adventofcode.com/2020/day/3
// Day 3: Toboggan Trajectory

auto traverseTerrain(string[] terrainMap, uint right, uint down) {
  uint x, y;
  string encounters;

  while(y < terrainMap.length) {
    encounters ~= terrainMap[y][x];

    x = (x + right) % terrainMap[y].length;
    y = y + down;
  }

  return encounters;
}

unittest {
  import std.algorithm : count;

  auto input = [
    "..##.......",
    "#...#...#..",
    ".#....#..#.",
    "..#.#...#.#",
    ".#...##..#.",
    "..#.##.....",
    ".#.#.#....#",
    ".#........#",
    "#.##...#...",
    "#...##....#",
    ".#..#...#.#"
  ];

  assert(input.traverseTerrain(3, 1).count('#') == 7);
}

void main() {
  import std.algorithm : count, filter, map, splitter;
  import std.array : array;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.array;
  input.traverseTerrain(3, 1).count('#').writeln;
}

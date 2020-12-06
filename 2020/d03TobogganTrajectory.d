// Advent of Code 2020 https://adventofcode.com/2020/day/3
// Day 3: Toboggan Trajectory

struct Vector { uint right, down; }

auto traverseTerrain(string[] terrainMap, Vector vec) {
  uint x, y;
  string encounters;

  while(y < terrainMap.length) {
    encounters ~= terrainMap[y][x];

    x = (x + vec.right) % terrainMap[y].length;
    y = y + vec.down;
  }

  return encounters;
}

auto trees(R)(R encounters) {
  import std.algorithm : count;

  return encounters.count('#');
}

enum slopes = [
  Vector(1, 1),
  Vector(3, 1),
  Vector(5, 1),
  Vector(7, 1),
  Vector(1, 2)
];

unittest {
  import std.algorithm : equal, map;

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

  assert(input.traverseTerrain(Vector(3, 1)).trees == 7);
  assert(
    slopes
      .map!(vector => input.traverseTerrain(vector).trees)
      .equal([2, 7, 3, 4, 2])
  );
}

void main() {
  import std.algorithm : filter, fold, map, splitter;
  import std.array : array;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.array;
  input.traverseTerrain(Vector(3, 1)).trees.writeln;
  slopes
    .map!(vector => input.traverseTerrain(vector).trees)
    .fold!((a, b) => a * b)(1L)
    .writeln;
}

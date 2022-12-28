// Advent of Code 2022 https://adventofcode.com/2022/day/8
// Day 8: Treetop Tree House

auto toGrid(T)(T input) {
  import std.algorithm : map;
  import std.array : array;
  import std.conv : to;

  ubyte[][] grid;

  foreach(inputRow; input) {
    grid ~= inputRow[].map!"a - '0'".map!(to!ubyte).array;
  }

  return grid;
}

bool visible(ubyte[][] grid, size_t x, size_t y) {
  import std.algorithm : all;
  import std.range : iota;

  auto height = grid[y][x];

  return iota(0, x).all!(x => grid[y][x] < height)
      || iota(grid[0].length-1, x, -1).all!(x => grid[y][x] < height)
      || iota(0, y).all!(y => grid[y][x] < height)
      || iota(grid.length-1, y, -1).all!(y => grid[y][x] < height);
}

size_t totalVisible(ubyte[][] grid) {
  import std.algorithm : cartesianProduct, count;
  import std.range : iota;

  return 2 * grid.length + 2 * (grid[0].length - 2)
    + cartesianProduct(iota(1, grid.length-1), iota(1, grid[0].length-1))
        .count!(t => grid.visible(t[1], t[0]));
}

auto countUntilInclusive(alias pred, R)(R range) {
  size_t count = 0;
  foreach(r; range) {
    count++;
    if (pred(r)) break;
  }
  return count;
}

auto scenicScore(ubyte[][] grid, long x, long y) {
  import std.range : iota;

  auto height = grid[y][x];

  return iota(x-1, -1, -1).countUntilInclusive!(x => grid[y][x] >= height)
       * iota(x+1, grid[0].length).countUntilInclusive!(x => grid[y][x] >= height)
       * iota(y-1, -1, -1).countUntilInclusive!(y => grid[y][x] >= height)
       * iota(y+1, grid.length).countUntilInclusive!(y => grid[y][x] >= height)
  ;
}

auto bestScenicScore(ubyte[][] grid) {
  import std.algorithm : cartesianProduct, map, maxElement;
  import std.range : iota;

  return cartesianProduct(iota(1, grid.length-1), iota(1, grid[0].length-1))
    .map!(t => grid.scenicScore(t[1], t[0]))
    .maxElement;
}

unittest {
  auto sampleData1 = [
    "30373",
    "25512",
    "65332",
    "33549",
    "35390",
  ];

  auto grid = sampleData1.toGrid;

  assert(grid.visible(1, 1));
  assert(grid.visible(2, 1));
  assert(!grid.visible(3, 1));

  assert(grid.visible(1, 2));
  assert(!grid.visible(2, 2));
  assert(grid.visible(3, 2));

  assert(!grid.visible(1, 3));
  assert(grid.visible(2, 3));
  assert(!grid.visible(3, 3));

  assert(grid.totalVisible == 21);

  assert(grid.scenicScore(2, 1) == 4);
  assert(grid.scenicScore(2, 3) == 8);
  assert(grid.bestScenicScore == 8);
}

void main() {
  import std.algorithm : splitter;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");

  data.toGrid.totalVisible.writeln;
  data.toGrid.bestScenicScore.writeln;
}
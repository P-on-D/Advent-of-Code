// Advent of Code 2020 https://adventofcode.com/2020/day/11
// Day 11: Seating System

struct SeatingSystem(R) {
  R currentState;
  ulong width, height;

  this(R input) in (input.length > 0) {
    currentState = input;
    height = currentState.length;
    width = currentState[0].length;
  }

  R nextRound() {
    R nextState;

    foreach(row; 0..height) {
      string nextRow;

      foreach(col; 0..width) {
        char nextCol = currentState[row][col];

        if (nextCol != '.') {
          auto adjOcc = adjacentOccupied(row, col);

          if (isOccupied(row, col)) {
            if (adjOcc >= 4) nextCol = 'L';
          } else {
            if (adjOcc == 0) nextCol = '#';
          }
        }

        nextRow ~= nextCol;
      }

      nextState ~= nextRow;
    }

    currentState = nextState;
    return currentState;
  }

  auto seatsOccupied() {
    import std.algorithm : count, map, sum;
    return currentState.map!(r => r.count('#')).sum;
  }

  auto isOccupied(ulong row, ulong col) {
    return row < height && col < width ? currentState[row][col] == '#' : false;
  }

  auto adjacentOccupied(ulong row, ulong col) {
    auto occupied = 0;

    foreach(drow; -1..2) {
      foreach(dcol; -1..2) {
        if (!(drow == 0 && dcol == 0)) {
          occupied += isOccupied(row + drow, col + dcol);
        }
      }
    }

    return occupied;
  }
}

unittest {
  import std.algorithm : equal, each;

  auto input = [
    "L.LL.LL.LL",
    "LLLLLLL.LL",
    "L.L.L..L..",
    "LLLL.LL.LL",
    "L.LL.LL.LL",
    "L.LLLLL.LL",
    "..L.L.....",
    "LLLLLLLLLL",
    "L.LLLLLL.L",
    "L.LLLLL.LL",
  ];

  auto seatingSystem = SeatingSystem!(string[])(input);

  assert(seatingSystem.seatsOccupied == 0);

  assert(seatingSystem.nextRound.equal([
    "#.##.##.##",
    "#######.##",
    "#.#.#..#..",
    "####.##.##",
    "#.##.##.##",
    "#.#####.##",
    "..#.#.....",
    "##########",
    "#.######.#",
    "#.#####.##",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.LL.L#.##",
    "#LLLLLL.L#",
    "L.L.L..L..",
    "#LLL.LL.L#",
    "#.LL.LL.LL",
    "#.LLLL#.##",
    "..L.L.....",
    "#LLLLLLLL#",
    "#.LLLLLL.L",
    "#.#LLLL.##",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.##.L#.##",
    "#L###LL.L#",
    "L.#.#..#..",
    "#L##.##.L#",
    "#.##.LL.LL",
    "#.###L#.##",
    "..#.#.....",
    "#L######L#",
    "#.LL###L.L",
    "#.#L###.##",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.#L.L#.##",
    "#LLL#LL.L#",
    "L.L.L..#..",
    "#LLL.##.L#",
    "#.LL.LL.LL",
    "#.LL#L#.##",
    "..L.L.....",
    "#L#LLLL#L#",
    "#.LLLLLL.L",
    "#.#L#L#.##",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.#L.L#.##",
    "#LLL#LL.L#",
    "L.#.L..#..",
    "#L##.##.L#",
    "#.#L.LL.LL",
    "#.#L#L#.##",
    "..L.L.....",
    "#L#L##L#L#",
    "#.LLLLLL.L",
    "#.#L#L#.##",
  ]));

  assert(seatingSystem.seatsOccupied == 37);
}

void main() {
  import std.algorithm : equal, map, splitter;
  import std.array : array;
  import std.conv : to;
  import std.path : setExtension;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto input = data.map!(to!string).array;
  auto seatingSystem = SeatingSystem!(string[])(input);
  string[] prevState;

  do {
    prevState = seatingSystem.currentState;
  } while(!prevState.equal(seatingSystem.nextRound));

  seatingSystem.seatsOccupied.writeln;
}

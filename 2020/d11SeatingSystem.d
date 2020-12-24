// Advent of Code 2020 https://adventofcode.com/2020/day/11
// Day 11: Seating System

struct SeatingSystem(R) {
  R currentState;
  ulong width, height;
  uint occupancyLimit = 4;

  this(R input) in (input.length > 0) {
    currentState = input;
    height = currentState.length;
    width = currentState[0].length;
  }

  this(R input, uint limit) in (input.length > 0) {
    this(input);
    occupancyLimit = limit;
  }

  R nextRound() {
    R nextState;

    foreach(row; 0..height) {
      string nextRow;

      foreach(col; 0..width) {
        char nextCol = currentState[row][col];

        if (nextCol != '.') {
          auto adjOcc = occupancyLimit == 4
            ? adjacentOccupied(row, col)
            : visibleOccupied(row, col);

          if (isOccupied(row, col)) {
            if (adjOcc >= occupancyLimit) nextCol = 'L';
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

  auto visibleOccupied(ulong row, ulong col) {
    auto occupied = 0;

    foreach(drow; -1..2) {
      foreach(dcol; -1..2) {
        if (!(drow == 0 && dcol == 0)) {
          occupied += canSeeOccupied(row, drow, col, dcol);
        }
      }
    }

    return occupied;
  }

  auto canSeeOccupied(ulong row, int drow, ulong col, int dcol) {
    do {
      row += drow;
      col += dcol;
    } while (row < height && col < width && currentState[row][col] == '.');

    return isOccupied(row, col);
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

  seatingSystem = SeatingSystem!(string[])([
    ".......#.",
    "...#.....",
    ".#.......",
    ".........",
    "..#L....#",
    "....#....",
    ".........",
    "#........",
    "...#.....",
  ], 5);

  assert(seatingSystem.currentState[4][3] == 'L');
  assert(seatingSystem.currentState[4][2] == '#');
  assert(seatingSystem.canSeeOccupied(4, 0, 3, -1));
  assert(seatingSystem.visibleOccupied(4, 3) == 8);

  seatingSystem = SeatingSystem!(string[])([
    ".##.##.",
    "#.#.#.#",
    "##...##",
    "...L...",
    "##...##",
    "#.#.#.#",
    ".##.##.",
  ], 5);

  assert(seatingSystem.visibleOccupied(3, 3) == 0);

  seatingSystem = SeatingSystem!(string[])(input, 5);

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
    "#.LL.LL.L#",
    "#LLLLLL.LL",
    "L.L.L..L..",
    "LLLL.LL.LL",
    "L.LL.LL.LL",
    "L.LLLLL.LL",
    "..L.L.....",
    "LLLLLLLLL#",
    "#.LLLLLL.L",
    "#.LLLLL.L#",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.L#.##.L#",
    "#L#####.LL",
    "L.#.#..#..",
    "##L#.##.##",
    "#.##.#L.##",
    "#.#####.#L",
    "..#.#.....",
    "LLL####LL#",
    "#.L#####.L",
    "#.L####.L#",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.L#.L#.L#",
    "#LLLLLL.LL",
    "L.L.L..#..",
    "##LL.LL.L#",
    "L.LL.LL.L#",
    "#.LLLLL.LL",
    "..L.L.....",
    "LLLLLLLLL#",
    "#.LLLLL#.L",
    "#.L#LL#.L#",
  ]));

  assert(seatingSystem.nextRound.equal([
    "#.L#.L#.L#",
    "#LLLLLL.LL",
    "L.L.L..#..",
    "##L#.#L.L#",
    "L.L#.#L.L#",
    "#.L####.LL",
    "..#.#.....",
    "LLL###LLL#",
    "#.LLLLL#.L",
    "#.L#LL#.L#",

  ]));

  assert(seatingSystem.nextRound.equal([
    "#.L#.L#.L#",
    "#LLLLLL.LL",
    "L.L.L..#..",
    "##L#.#L.L#",
    "L.L#.LL.L#",
    "#.LLLL#.LL",
    "..#.L.....",
    "LLL###LLL#",
    "#.LLLLL#.L",
    "#.L#LL#.L#",
  ]));

  assert(seatingSystem.seatsOccupied == 26);
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

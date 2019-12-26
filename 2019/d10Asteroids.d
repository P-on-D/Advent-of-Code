auto seenFrom(string[] input, int x, int y) {
  bool isAsteroid(int x, int y) {
    return input[x][y] == '#'; // ?
  }

  int lookWith(int dx, int dy) {
    int cx = x+dx, cy = y+dy;

    while(cx >= 0 && cy >= 0 && cy < input.length && cx < input[cy].length) {
      if(isAsteroid(cx, cy)) return 1;
      cx += dx;
      cy += dy;
    }

    return 0;
  }

  return lookWith(1,0) + lookWith(-1,0)
       + lookWith(0,1) + lookWith(0,-1);
}

auto visibility(string[] input) {
  int[][] vis;

  foreach(int row, line; input) {
    int[] cellvis;
    foreach(int col, cell; line) {
      cellvis ~= cell == '.' ? 0 : seenFrom(input, row, col);
    }
    vis ~= cellvis;
  }

  return vis;
}

unittest {
  void test(T, U)(T received, U expected) {
    import std.format;
    assert(received == expected, format!"Expected %s received %s"(expected, received));
  }

  test(
    visibility([
      ".#..#"
    , "....."
    , "#####"
    , "....#"
    , "...##"
    ]),
    [
      [0,7,0,0,7]
    , [0,0,0,0,0]
    , [6,7,7,7,5]
    , [0,0,0,0,7]
    , [0,0,0,8,7]
    ]
  );
}

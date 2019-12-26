auto visibility(string[] input) {
  int[][] vis;

  foreach(line; input) {
    int[] cellvis;
    foreach(cell; line) {
      cellvis ~= cell == '.' ? 0 : 7;
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

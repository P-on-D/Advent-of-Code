unittest {
  int input = 111111;

  int i = input % 10;
  int n = input / 10;
  bool decreasing;
  bool doubleadjacent;

  do {
    int r = n % 10;
    n /= 10;
    if (r > i) { decreasing = true; break; }
    if (r == i) doubleadjacent = true;
    i = r;
  } while(n > 0);

  assert(!decreasing);
  assert(doubleadjacent);
}

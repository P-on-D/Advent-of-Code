bool meetsCriteria(int input) {
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

  return !decreasing && doubleadjacent;
}

unittest {
  assert(meetsCriteria(111111));
  assert(!meetsCriteria(223450));
  assert(!meetsCriteria(123789));
}

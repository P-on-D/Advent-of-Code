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

bool meetsNewCriteria(int input) {
  int i = input % 10;
  int n = input / 10;
  int l = 1;
  bool decreasing;
  bool doubleobserved;

  do {
    int r = n % 10;
    n /= 10;
    if (r > i) { decreasing = true; break; }
    if (r == i) {
      ++l;
    } else {
      if (l==2) doubleobserved = true;
      l = 1;
    }
    i = r;
  } while(n > 0);

  return !decreasing && (doubleobserved || l == 2);
}

unittest {
  assert(meetsCriteria(111111));
  assert(!meetsCriteria(223450));
  assert(!meetsCriteria(123789));

  assert(meetsNewCriteria(112233));
  assert(!meetsNewCriteria(123444));
  assert(meetsCriteria(111122));
} version (unittest) {} else {

void main() {
  int meets;

  for(int i = 231832; i <= 767346; i++) {
    meets += meetsCriteria(i);
  }

  import std.stdio;
  meets.writeln;
}

}
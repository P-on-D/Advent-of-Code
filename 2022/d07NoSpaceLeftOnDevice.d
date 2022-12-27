// Advent of Code 2022 https://adventofcode.com/2022/day/7
// Day 7: No Space Left On Device

struct Entry {
  Entry *parent;
  string name;
  bool isDir;
  size_t size;
  Entry[] children;
}

Entry processTranscript(string[] transcript) {
  import std.algorithm : find, map;
  import std.array : split;
  import std.conv : to;
  import std.format : format;
  import std.exception : enforce;

  Entry root = Entry(null, "/", true, 0, []);

  bool inListing = false;
  Entry *currentDir = &root;

  foreach(line; transcript) {
    auto parts = line.split(" ");

    if (parts[0] == "$") {
      inListing = false;

      if (parts[1] == "ls") {
        inListing = true;
      } else {
        if (parts[2] == "/") {
          currentDir = &root;
        } else if (parts[2] == "..") {
          currentDir = currentDir.parent;
        } else {
          auto nextCurrentDir = currentDir.children.find!(entry => entry.name == parts[2]);
          enforce(nextCurrentDir.length, format!"Can't cd to %s in %s"(parts[2], currentDir.name));
          currentDir = nextCurrentDir.ptr;
        }
      }
    } else if (inListing) {
      if (parts[0] == "dir") {
        currentDir.children ~= Entry(currentDir, parts[1], true);
      } else {
        currentDir.children ~= Entry(currentDir, parts[1], false, parts[0].to!size_t);
      }
    }
  }

  return root;
}

size_t directorySize(Entry dir) {
  import std.algorithm : map, sum;

  return dir.children
    .map!(entry => entry.isDir ? entry.directorySize : entry.size)
    .sum;
}

Entry[] findDirectories(Entry dir) {
  Entry[] found = [];

  if (dir.isDir) {
    found ~= dir;
    foreach(child; dir.children) {
      if (child.isDir) {
        found ~= child.findDirectories;
      }
    }
  }

  return found;
}
unittest {
  auto sampleData1 = [
    "$ cd /",
    "$ ls",
    "dir a",
    "14848514 b.txt",
    "8504156 c.dat",
    "dir d",
    "$ cd a",
    "$ ls",
    "dir e",
    "29116 f",
    "2557 g",
    "62596 h.lst",
    "$ cd e",
    "$ ls",
    "584 i",
    "$ cd ..",
    "$ cd ..",
    "$ cd d",
    "$ ls",
    "4060174 j",
    "8033020 d.log",
    "5626152 d.ext",
    "7214296 k",
  ];

  Entry root = sampleData1.processTranscript;

  import std.algorithm, std.array;

  assert(root.directorySize == 48381165);
  assert(root.findDirectories.map!"a.name".array == ["/", "a", "e", "d"]);
  assert(root.findDirectories.find!"a.name == \"e\"".front.directorySize == 584);
  assert(root.findDirectories.find!"a.name == \"a\"".front.directorySize == 94853);
  assert(root.findDirectories.find!"a.name == \"d\"".front.directorySize == 24933642);

  assert(root.findDirectories.map!directorySize.filter!"a <= 100000".sum == 95437);
}

void main() {}
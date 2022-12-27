// Advent of Code 2022 https://adventofcode.com/2022/day/5
// Day 5: Supply Stacks

char[][] parseStackDrawing(string[] stackDrawing) {
  import std.range;

  // the number of stacks will derived from the last line of the drawing
  // the drawing appears to be space-padded
  auto noOfStacks = stackDrawing.back.length / 4 + 1;

  char[][] stacks = new char[][noOfStacks];

  stackDrawing.popBack;
  foreach_reverse(rowDrawing; stackDrawing) {
    for(size_t cratePos = 1, column = 0; cratePos < rowDrawing.length; cratePos += 4, column++) {
      if (rowDrawing[cratePos] != ' ') {
        stacks[column] ~= rowDrawing[cratePos];
      }
    }
  }

  return stacks;
}

struct ProcedureStep {
  size_t howMany;
  size_t from;
  size_t to;
}

ProcedureStep toProcedureStep(string line) {
  import std.format;

  ProcedureStep step;
  line.formattedRead("move %d from %d to %d", step.howMany, step.from, step.to);
  return step;
}

auto applyMove(char[][] stacks, size_t from, size_t to) {
  import std.range;

  stacks[to-1] ~= stacks[from-1].back;
  stacks[from-1].popBack;
  return stacks;
}

auto applyStep(char[][] stacks, ProcedureStep step) {
  do {
    stacks.applyMove(step.from, step.to);
  } while(--step.howMany);
  return stacks;
}

auto applyStepAtomic(char[][] stacks, ProcedureStep step) {
  stacks[step.to-1] ~= stacks[step.from-1][$-step.howMany..$];
  stacks[step.from-1].length -= step.howMany;
  return stacks;
}

unittest {
  auto sampleData1 = [
    "    [D]    ",
    "[N] [C]    ",
    "[Z] [M] [P]",
    " 1   2   3 ",
    "",
    "move 1 from 2 to 1",
    "move 3 from 1 to 3",
    "move 2 from 2 to 1",
    "move 1 from 1 to 2",
  ];

  import std.algorithm, std.array, std.range, std.stdio;

  auto sampleDataSplit = sampleData1.split("");
  auto stackDrawing = sampleDataSplit[0];
  auto procedure = sampleDataSplit[1];

  assert(stackDrawing.length == 4);
  assert(procedure.length == 4);

  auto stacks = stackDrawing.parseStackDrawing;
  assert(stacks == ["ZN", "MCD", "P"]);

  auto steps = procedure.map!toProcedureStep.array;
  assert(steps == [
    ProcedureStep(1, 2, 1),
    ProcedureStep(3, 1, 3),
    ProcedureStep(2, 2, 1),
    ProcedureStep(1, 1, 2)
  ]);

  assert(stacks.applyStep(steps[0]) == ["ZND", "MC", "P"]);
  assert(stacks.applyStep(steps[1]) == ["", "MC", "PDNZ"]);
  assert(stacks.applyStep(steps[2]) == ["CM", "", "PDNZ"]);
  assert(stacks.applyStep(steps[3]) == ["C", "M", "PDNZ"]);

  assert(stacks.map!back.array == "CMZ");

  stacks = stackDrawing.parseStackDrawing;
  steps.each!(step => stacks.applyStepAtomic(step));
  assert(stacks.map!back.array == "MCD");
}

void main() {
  import std.algorithm : each, map, splitter;
  import std.array : array, split;
  import std.path : setExtension;
  import std.range : back;
  import std.stdio;

  auto data = import(__FILE__.setExtension("txt")).splitter("\n");
  auto dataSplit = data.array.split("");

  auto stacks = dataSplit[0].parseStackDrawing;
  auto procedure = dataSplit[1].map!toProcedureStep;

  procedure.each!(step => stacks.applyStep(step));

  stacks.map!back.writeln;
}

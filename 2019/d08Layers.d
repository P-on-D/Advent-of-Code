void main() {
  import std.algorithm, std.range, std.stdio;

  auto width = 25, height = 6, stride = width * height;
  auto maxLayers = 100;
  ubyte[] buff = new ubyte[width*height*maxLayers+1];

  auto grid = stdin.rawRead(buff);
  auto leastZeros = stride;
  auto leastFunc = 0;

  foreach(layer; grid.chunks(stride)) {
    auto zeros = cast(int)layer.count!"a == 48";

    if (zeros < leastZeros) {
      leastZeros = zeros;
      leastFunc = cast(int)(layer.count!"a == 49" * layer.count!"a == 50");
    }
  }

  leastFunc.writeln;

  ubyte[] frame = new ubyte[width*height];
  frame[] = 50;

  foreach(layer; grid.chunks(stride)) {
    bool transparent = false;
    foreach(index, pixel; frame) {
      if (pixel == 50) {
        frame[index] = layer[index];
        transparent = true;
      }
    }
    if (!transparent) break;
  }

  foreach(line; frame.chunks(width)) {
    line.map!(c => c == 49 ? '0' : ' ').writeln;
  }
}

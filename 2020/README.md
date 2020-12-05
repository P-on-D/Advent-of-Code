Season's greetings! Paul here again with another attempt at Advent of Code for 2020.

I'll be solving the problems once again using the D language. I values its inbuilt unit
testing, easy-to-use syntax, compile-time function execution and excellent performance.

For development I'm using the latest official DMD Docker image dlang2/dmd-ubuntu. For
any problems that require compilation to solve quickly I use the LDC docker image. I may
also be tempted into buying an M1 Mac Mini to compare as LDC already supports the platform
for cross-compilation.

As most (if not all) AoC problems have an accompanying data file, each solution program will
automatically compile in the .txt file with the same base name as the D source file if no
filename is given as an argument. This allows the programs to be standalone for my personal
data files and still work with other's files.

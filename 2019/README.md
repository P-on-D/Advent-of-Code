Hi, I'm Paul and I'm spending the holiday season tackling the nefarious [Advent of Code](https://adventofcode.com)
programming puzzles using the [D language](https://dlang.org).

I'm learning to write performant, well-behaved programs using vanilla D.

My development environment is an [iMac](https://support.apple.com/kb/SP731) (Retina 5K, 27-inch, Late 2015) with
4 GHz Quad-Core i7 and 16GB RAM running [macOS Catalina](https://www.apple.com/uk/macos/catalina/). I bought [Sublime Text](https://sublimetext.com) for editing and [Sublime Merge](https://sublimemerge.com) for source control.

My runtime environment is [DMD 2.080.0](https://dlang.org/changelog/2.080.0.html) in a [Docker](https://docs.docker.com/docker-for-mac/) container lightly
customised from the [canonical image](https://hub.docker.com/r/dlanguage/dmd/) - Dockerfile enclosed. The container gets
2 CPUs and 4GB RAM.

My operating model is to build tests for the example input of part 1, commit
when they pass, refactor into a program that passes the tests using example
input from a file, commit that, run the program with the real part 1 input,
document and commit that, fumble around aimlessly figuring out why the answer
is wrong, commit and document the working result, review the working result,
amend as agreed during review, commit and document running that.

Repeat for part 2.

Repeat for each day.

And try to have fun!
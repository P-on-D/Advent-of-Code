Season's greetings! Back with Advent of Code after a year-long hiatus.

I have a different development environment from before: a base model M1 Macbook Air (8GB RAM, 8 CPU cores, 7 GPU cores). I'm still planning to use DMD as the main development compiler so I'll
be depending on Rosetta for that. Final versions of each puzzle I plan to compile for ARM using
LDC to compare performance where that's reasonable.

I'm not sure what to use for virtualisation. I still want to use Docker as it makes integrating
the tools into my workflow quite easy but that's going to require an ARM build of the DMD compiler
which doesn't exist.

I _really_ don't want to install any of the tools locally. That said, Docker for Desktop Mac claims to be able to both build _and_ run x86 images. Can I get DMD up?

Well, the trouble seems to be, where are the latest images?
  I can get DMD 2.096.1 (a bit old but usable) from the image dlang2/dmd-ubuntu:latest
  It complains a bit about being run in the wrong platform but comes back with a version
  It also compiles and runs unit tests and basic programs. Good enough.

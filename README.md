# BBC BASIC+ for Z80

This is modified source code based on [BBC BASIC (Z80)](http://www.bbcbasic.co.uk/bbcbasic/z80basic.html) by R.T. Russell, who [kindly agreed](http://cowlark.com/2019-06-14-bbcbasic-opensource/index.html) to release the original sources under the [zlib](COPYING) license at the request of David Given.  David published the sources as part of his [cpmish](https://github.com/davidgiven/cpmish) project.

The original sources released by R.T. Russell are in the initial commit.  I have made the following modifications:

- Modified sources to assemble with [z88dk](https://github.com/z88dk/z88dk)'s z80asm
- Fixed a [bug](https://github.com/davidgiven/cpmish/issues/20) that causes the RUN command to hang under emulators.
- Moved hardware-specific functions from patch.asm to hardware.asm.
- Implemented CLS, TAB, and COLOUR using ANSI escape codes
- Added a Makefile and this README

Planned modifications:

- Graphics support for the TMS9918A video chip for use with my [video card](https://github.com/jblang/TMS9918A/) for the RC2014.
- Sound support for my SN76489 sound card and/or Ed Brindley's YM2149 sound card
- Joystick support for my Game Controller board supporting ColecoVision, Sega, and Atari controllers.
- Back port additional functionality from modern BBC BASIC.

## Build Instructions

Download and install [z88dk](https://github.com/z88dk/z88dk) (compile if necessary). Make sure z88dk's `bin` directory containing `z80asm` is in your path.

Run `make` to build bbcbasic.com.

If make is not available, run:

```
z80asm -obbcbasic.com -b -d -l -m main.asm exec.asm eval.asm fpp.asm hardware.asm cpm.asm ram.asm
```
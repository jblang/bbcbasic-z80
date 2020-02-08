# BBC BASIC (Z80) by R.T. Russell

This is the source code for [BBC BASIC (Z80)](http://www.bbcbasic.co.uk/bbcbasic/z80basic.html) by R.T. Russell, who [kindly agreed](http://cowlark.com/2019-06-14-bbcbasic-opensource/index.html) to release it under the [zlib](COPYING) license at the request of David Given.  David published the sources as part of his [cpmish](https://github.com/davidgiven/cpmish) project.

The original sources provided by R.T. Russell are in the initial commit.  I modified the sources so that they could be assembled by [z88dk](https://github.com/z88dk/z88dk)'s z80asm, then added a Makefile and this README. I have also fixed a [bug](https://github.com/davidgiven/cpmish/issues/20) that causes the RUN command to hang under emulators.

My next steps will be to add graphics support for the TMS9918A video chip so that I can use it with my [video card](https://github.com/jblang/TMS9918A/) for the RC2014.
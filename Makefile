SRCS = patch.asm main.asm exec.asm eval.asm fpp.asm sorry.asm cmos.asm ram.asm

bbcbasic.com: 
	z80asm -b -l -m $(SRCS)
	appmake +glue --clean -b patch
	mv patch__.bin bbcbasic.com

clean:
	rm -f *.o *.err *.lis *.map *.com *.bin

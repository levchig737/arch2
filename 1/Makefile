greetings: greetings.o
	ld -melf_i386 -o greetings greetings.o

greetings.o: greetings.s
	as -ahlsm=greetings.lst --32 -gstabs+ -o greetings.o greetings.S
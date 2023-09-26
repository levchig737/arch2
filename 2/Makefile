FILE=testcpuid
CFLAGS= -ahlsm=$(FILE).lst -gstabs+ --32
LFLAGS= -m elf_i386

all: $(FILE)

$(FILE).o: *.S
	as $(CFLAGS) -o $(FILE).o $(FILE).S

$(FILE): $(FILE).o
	ld $(LFLAGS) $(FILE).o -o $(FILE)

clean:
	rm -f $(FILE).o $(FILE)

.INTERMEDIATE: $(FILE).o


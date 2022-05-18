all: dodawanie_259105 odejmowanie_259105 mnozenie_259105

dodawanie_259105: dodawanie_259105.o
	ld -melf_i386 dodawanie_259105.o -o dodawanie_259105

dodawanie_259105.o: dodawanie_259105.s
	as --32 dodawanie_259105.s -o dodawanie_259105.o

odejmowanie_259105: odejmowanie_259105.o
	ld -melf_i386 odejmowanie_259105.o -o odejmowanie_259105

odejmowanie_259105.o: odejmowanie_259105.s
	as --32 odejmowanie_259105.s -o odejmowanie_259105.o

mnozenie_259105: mnozenie_259105.o
	ld -melf_i386 mnozenie_259105.o -o mnozenie_259105

mnozenie_259105.o: mnozenie_259105.s
	as --32 mnozenie_259105.s -o mnozenie_259105.o

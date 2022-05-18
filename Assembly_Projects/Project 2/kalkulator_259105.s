	.code32
SYSCALL = 0x80
SYSEXIT = 1
EXIT_SUCCESS_CALL = 0
SYSOUT = 1
SYSWRITE = 4
SYSREAD = 3
SYSIN = 0

wejscie_dl = 8
wejscie_dl_koniec = 8
wejscie_dl_2 = 8

.data

wejscieDlugos: .space wejscie_dl
WejscieKon: .space wejscie_dl_koniec
WejsieTryb: .space wejscie_dl_2

element1_D: .double 0.0
element2_D: .double 0.0

element_1: .float 2.00
element_2: .float 10.00

.text

format_wyjscia_precyzja1: .asciz "%f"
format_wyjscia_precyzja2: .asciz "%lf"

wyborTrybu: .asciz "\nWybor precyzji obliczen:\n1.Precyzja pojedyncza(Float)\n2.Precyzja podwojna(Double):\n "
wyborTrybu_len= .-wyborTrybu

getFirstNum: .asciz "\nPierwszy element: "
getFirstNum_len= .-getFirstNum

getSecondNum: .asciz "\nKolejny element: "
getSecondNum_len= .-getSecondNum

wyborOperacji: .ascii "Wybor operacji:\n1.Dodawanie\n2.Mnozenie\n3.Dzielenie\n4.Odejmowanie:\n"
wyborOperacji_len= .-wyborOperacji

checkoutMessage: .ascii "Wyniki przedstawione w gdb (bez wprowadzania dodatkowych komend, mozna zobaczyc w st(0))\n"
checkoutMessage_len= .-checkoutMessage

.global main 

CLEAR:
# Wyczyszcenie rejstrów floating point w mechanizmie FPU
# Operacja pomocnicza, sluzaca zabezpieczeniu
# trafnosci wynikow.

ffree %st(0)
ffree %st(1)

main:
# wybor precyzji obliczen wyswietlany uzytkownikowi
mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $wyborTrybu, %ecx
mov $wyborTrybu_len, %edx
int $SYSCALL

# Zaladowanie wyboru precyzji przez uzytkownika
mov $SYSREAD, %eax
mov $SYSIN, %ebx
mov $WejsieTryb, %ecx
mov $wejscie_dl_2, %edx
int $SYSCALL

# Instrukcja warunkowa odpowiadajaca za przeskok do funkcji
# zajmujacej sie odpowiednia precyzja
# Wyjasnienie: Posluguje sie tutaj flaga cmp w celu porownania wartosi hexadecymalnej
# z wyborem uzytkownika, wartosc zapisana na 8 bitowym rejestrze %ecx porownana z
# wartoscia decymalna 101000110001 (0xa31), jest rowna %ecx przy zapisaniu wartosci 1,
# adekwatnie wykonalem taki zabieg rowniez dla zapisania wartosci 2

mov WejsieTryb, %ecx
cmp $0xa31, %ecx
je F_Precision
cmp $0xa32, %ecx
je D_Precision
JMP EXIT

F_Precision:
# Zaciagniecie pierwszego elementu
# operacji arytmetycznej podanej przez uzytkownika
mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $getFirstNum, %ecx
mov $getFirstNum_len, %edx
int $SYSCALL

# W celu zapobiegniecia sytuacji, gdzie liczba Float/Double
# zostalaby zle zapisana przez procesor, zachowywuje na stacku informacje
# odnosnie wielkosci oraz precyzji danej liczby Float/Double
# Nastpenie posluguje się pomocnicza funkcja scanf w celu zapisania elementu

push $element_1
push $format_wyjscia_precyzja1
call scanf

# Zaciagniecie drugiego elementu
# Lustrzane co do elementu 1
mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $getSecondNum, %ecx
mov $getSecondNum_len, %edx
int $SYSCALL

push $element_2
push $format_wyjscia_precyzja1
call scanf

# Wyswietlenie menu odpowiedzialnego za wybor operacji arytmetycznej
mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $wyborOperacji, %ecx
mov $wyborOperacji_len, %edx
int $SYSCALL

# Wczytanie wyboru operacji arytmetycznej przez uzytkownika
mov $SYSREAD, %eax
mov $SYSIN, %ebx
mov $wejscieDlugos, %ecx
mov $wejscie_dl, %edx
int $SYSCALL

WARUNEK:
# Bardziej rozbudowana instrukcja warunkowa, bazujaca jednak na identycznym
# mechanizmie jak w przypadku wyboru precyzji.
# Przy odpowiedniej rownosci bitowej porownywanych wartosci
# nastepuje przeskok do odpowiedniej flagi - operacji arytmetycznej
# Operacje na tym etapie sa wykonywane we fladze F_Precision
# wiec automatycznie wiemy, ze bedziemy wykonywac operacje 
# na liczbach z pojedyncza precyzja
mov wejscieDlugos, %ecx
cmp $0xa31, %ecx
je Dodawanie_Float
cmp $0xa32, %ecx
je Mnozenie_Float
cmp $0xa33, %ecx
je Dzielenie_Float
cmp $0xa34, %ecx
je Odejmowanie_Float
JMP EXIT

Dodawanie_Float:

# Glowna czesc programu - operacje arytmetyczne
# Do operacji na liczbach typu floating point 
# wykorystuje mechanizm FPU wraz z wszystkimi 
# operacjami zawartymi wobec dzialan na stosie rejestrów FPU.
# Poprzez dzialania na rejstrach stosu, mam pewnosc, ze podane
# przez uzytkownika liczby, ktore zostaly zapisane w opdowiedniej formie
# trafia do rejestrów, które również adekwatnie rozpoznaja typy
# floating point o pojedynczej oraz podwojnej precyzji.
# Głownymi instrukcjami na rejestrach, którymi się poslugiwalem
# byly flagi zaladowan elementów do rejestrow (fld), 
# flagi przeniesien na wybrany rejestr stosu (fst),
# flagi operacji arytmetycznych na tpie floating ponit
# w mechanizmie FPU - faddp, fsubp itp.
# instrukcje z dodatkiem 'p' (np. faddp) zostaly
# zaimplementowane w celu manipulacji stosem

# Sciagniecie elementu zapsianego w element_1 do rejestru st / st(0) - gora stostu FPU
fld element_1
# przeniesienie wartosci st do st(1), w celu 
# nastpeujacego sciagniecia kolejnej wartosci na wierzch
# stosu
fst %st(1)
# Sciagniecie elemntu zapisanego w element_1  do rejestru 
# nizej na stosie - st(1)
fld element_2
# Operacja dodawania na obu elementach,
# wynik zostaje zapisany w st(0)
faddp %st(1), %st(0)
jmp EXIT

Mnozenie_Float:
fld element_1
fst %st(1)
fld element_2
fmulp %st(1), %st(0)
jmp EXIT

Dzielenie_Float:
fld element_1
fst %st(1)
fld element_2
fdivp %st(0), %st(1)
jmp EXIT

Odejmowanie_Float:
fld element_1
fst %st(1)
fld element_2
# W przypadku odejmowania oraz dzielenie,
# nalezalo zamienic kolejnosciami rejestry st
# Wynik znajduj sie wciaz w st(0)
fsubp %st(0),%st(1)
jmp EXIT

D_Precision:
# Opis operacji dla liczb Double
# jest bardzo podobny wzgledem Float
# Jedyna roznica bylo dodanie "l"
# przy operacjach na rejestrach w celu wyszczegolnienia
# typu podwojej precyzji pzechowywanej w ich wnetrzu.

mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $getFirstNum, %ecx
mov $getFirstNum_len, %edx
int $SYSCALL

push $element1_D
push $format_wyjscia_precyzja2
call scanf


mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $getSecondNum, %ecx
mov $getSecondNum_len, %edx
int $SYSCALL

push $element2_D
push $format_wyjscia_precyzja2
call scanf

mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $wyborOperacji, %ecx
mov $wyborOperacji_len, %edx
int $SYSCALL

mov $SYSREAD, %eax
mov $SYSIN, %ebx
mov $wejscieDlugos, %ecx
mov $wejscie_dl, %edx
int $SYSCALL

mov wejscieDlugos, %ecx
cmp $0xa31, %ecx
je Dodawanie_Double
cmp $0xa32, %ecx
je Mnozenie_Double
cmp $0xa33, %ecx
je Dzielenie_Double
cmp $0xa34, %ecx
je Odejmowanie_Double
JMP EXIT

Dodawanie_Double:

# Tutaj mozna zauwazyc roznice w instrukcjach
# flagi z dodatkami "l" jak fldl ropoznaja ze 
# w rejestrach stosu FPU bedzie zapisana 
# wartosc floating point o podwojnej precyzji

fldl element1_D
fstl %st(1)
fldl element2_D
faddp %st(1), %st(0)
jmp EXIT

Mnozenie_Double:
fldl element1_D
fstl %st(1)
fldl element2_D
fmulp %st(1), %st(0)
jmp EXIT

Dzielenie_Double:
fldl element1_D
fstl %st(1)
fldl element2_D
fdivp %st(0), %st(1)
jmp EXIT

Odejmowanie_Double:
fldl element1_D
fstl %st(1)
fldl element2_D
fsubp %st(0), %st(1)
jmp EXIT


EXIT:
# Chekout message - wiadomosc konczaca program
mov $SYSWRITE, %eax
mov $SYSOUT, %ebx
mov $checkoutMessage, %ecx
mov $checkoutMessage_len, %edx
int $SYSCALL

mov $SYSEXIT, %eax
mov $EXIT_SUCCESS_CALL, %ebx
int $SYSCALL

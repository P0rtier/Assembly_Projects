.global _start

.data
# definicja skladnikow dodawania, wraz z okresleniem dlugosci struktury w b + logicznej

skladnik_1:
    .long 0x11012011, 0x11122314, 0x12353182, 0x55545353
    dl_skladnik = .-skladnik_1
    liczba_skladnika = dl_skladnik / 4

skladnik_2:
    .long 0x1a127111, 0x23114231, 0xf4f2fac1
    dl_skladnik2 = .-skladnik_2
    liczba_skladnika2 = dl_skladnik2 / 4


.bss
# definicja pomocniczej wartosci przeniesienie_value dla przeniesien ponad stan oraz sumy
# alokacja pamieci dla sumy = dlugosci skladnika_1, zalozenie, że zawsze zapisujemy 
# wieksza liczbe od gory (pierwsza pisemnie)
suma:
    .space dl_skladnik
przeniesienie_value:
    .space 4

.text

# Opis dzialania algorytmu:
# algorytm opiera sie na prostym dzialaniu arytmetycznym, wystepuje tutaj rowniez
# samodzielna manipulacja stosem (ukrywanie flag w celu braku niezamierzonej 
# modyfikacji flagi przeniesienia, w dalszym etapie programu wyciaganie wynikow
# oraz zapisywanie ich do sumy poprzez sciaganie elementow ze stosu oraz ustawianie
# ich w odpowiedniej kolejnosci)

# algorytm przewiduje mozliwosc dodawania liczb, ktore nie maja rownej wartosci bitowej
# jednak wymaga zapisania wiekszej liczby jako elementu 1 - skladnik_1
_start:
clc
pushf
movl $liczba_skladnika, %esi
movl $liczba_skladnika2, %edx

dodawanie:
    popf
    dec %esi
    dec %edx
    movl skladnik_1(,%esi,4), %eax
    adcl skladnik_2(,%edx,4), %eax
    push %eax
    pushf
    cmp $0, %edx
    jz dodawanie_ponad_stan
    cmp $0, %esi
    jz przeniesienie
    jmp dodawanie


dodawanie_ponad_stan:
    cmp $0, %esi
    jz przeniesienie
    dec %esi
    popf
    movl skladnik_1(,%esi,4), %eax
    adcl $0, %eax
    push %eax
    pushf
    jmp dodawanie_ponad_stan


przeniesienie:
    popf
    movl $0, przeniesienie_value
    jc przenies
    movl $liczba_skladnika, %esi
    addl $(dl_skladnik-4), %esp
    jmp checkout

przenies:
    movl $1, przeniesienie_value
    movl $liczba_skladnika, %esi
    addl $(dl_skladnik-4), %esp
    jmp checkout

checkout:
    dec %esi
    mov (%esp), %eax
    movl %eax, suma(,%esi,4)
    subl $4, %esp
    cmp $0, %esi
    jz koniec
    jmp checkout

koniec:
    mov $1, %eax
    mov $0, %ebx
    int $0x80

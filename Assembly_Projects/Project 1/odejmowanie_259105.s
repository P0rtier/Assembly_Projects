.global _start

.data
# definicja skladnikow odejmowania, wraz z okresleniem dlugosci struktury w b + logicznej
skladnik_1:
    .long 0x23010031, 0x201f2024, 0x23113322, 0x221a2324
    dl_skladnik = .-skladnik_1
    liczba_skladnika = dl_skladnik / 4

skladnik_2:
    .long 0x301f2024, 0x23113322, 0x221a2324
    dl_skladnik2 = .-skladnik_2
    liczba_skladnika2 = dl_skladnik2 / 4

.bss

# definicja pomocniczej wartosci przeniesienie_value dla przeniesien ponad stan oraz sumy
# alokacja pamieci dla roznicy = dlugosci skladnika_1, zalozenie, że zawsze zapisujemy 
# wieksza liczbe od gory (pierwsza pisemnie)

roznica:
    .space dl_skladnik
przeniesienie_value:
    .space 4

.text

# Opis dzialania algorytmu:
# algorytm opiera sie na prostym dzialaniu arytmetycznym, wystepuje tutaj rowniez
# samodzielna manipulacja stosem (ukrywanie flag w celu braku niezamierzonej 
# modyfikacji flagi przeniesienia, w dalszym etapie programu wyciaganie wynikow
# oraz zapisywanie ich do roznicy poprzez sciaganie elementow ze stosu oraz ustawianie
# ich w odpowiedniej kolejnosci)

# algorytm przewiduje mozliwosc odejmowania liczb, ktore nie maja rownej wartosci bitowej
# jednak wymaga zapisania wiekszej liczby jako elementu 1 - skladnik_1

_start:
clc
pushf
movl $liczba_skladnika, %esi
movl $liczba_skladnika2, %edx

odejmowanie:
    popf
    dec %esi
    dec %edx
    movl skladnik_1(,%esi,4), %eax
    sbbl skladnik_2(,%edx,4), %eax
    push %eax
    pushf
    cmp $0, %edx
    jz odejmowanie_ponad_stan
    cmp $0, %esi
    jz przeniesienie
    jmp odejmowanie

odejmowanie_ponad_stan:
    cmp $0, %esi
    jz przeniesienie
    dec %esi
    popf
    movl skladnik_1(,%esi,4), %eax
    sbbl $0, %eax
    push %eax
    pushf
    jmp odejmowanie_ponad_stan


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
    movl %eax, roznica(,%esi,4)
    subl $4, %esp
    cmp $0, %esi
    jz koniec
    jmp checkout

koniec:
    mov $1, %eax
    mov $0, %ebx
    int $0x80

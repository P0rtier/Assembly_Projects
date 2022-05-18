.global _start

.data

# definicja skladnikow mnozenia wraz z okresleniem dlugosci struktury w b + logicznej

mnozna:
    .long 0x11111111, 0x12312312, 0x15515115
    mnozna_wielk = .-mnozna
    mnozna_dlug = mnozna_wielk/4
mnoznik:
    .long 0x22110033, 0x33121040, 0x45320012
    mnoznik_wielk = .-mnoznik
    mnoznik_dlug = (mnoznik_wielk)/4
    wielk_wynikowa = mnozna_wielk + mnoznik_wielk
.bss

# definicja sumy, alokacja pamieci dla sumy => korzystam z pomocnieczej zmiennej wielk_wynikowa 
# poniewaz w wyniku mnozenia, wielkosc (b + logiczna) iloczynu bedzie wieksza niz czesci skladowych,
# w zwiazku z tym alokuje pamiec na (2x mnoznej w przypadku rownych dlugosci) sume bitow obu czynnikow

iloczyn:
    .space wielk_wynikowa

.text

# Opis algorytmu:
# Algorytm opiera sie na petli glownej oraz petli zagniezdzonej, gdzie iterujemy po kolejnych elementach mnoznej oraz mnoznika,
# wymnazajac oba czynniki (niezaleznie na ktorym indeksie sie znajdujemy), otrzymujemy wyzsze 4 bajty w rejestrze %eax, a nizsze w $edx.
# nastepnie w algorytmie wystepuje odpowiednia manipulacja dodawaniami oraz przeniesieniami wlasciwych elementow oraz ich czesci do wyniku.
# kluczowym miejscem jest fragment odpowiedzialny za obliczanie przesuniecia (wlasciwej wartosci przeniesienia, oraz miejsca w ktore powinno to zostac wstawione)
# zostalo to zaimplementowane poprzez manipulacje rejestrami wraz z przeniesieniem w liniach 54-57, a samo przesuniecie jest odpowiednio wstawione do iloczynu 
# w linii 59

_start:
    movl $0, %esi
petla_z:
    cmpl $mnozna_dlug, %esi
    jz koniec
    movl $0, %edi
    movl $0, %ebx

petla_w:
    movl $0, %ecx
    cmpl $mnoznik_dlug, %edi
    jz koniec_pw
    movl mnozna(,%esi,4), %eax
    movl mnoznik(,%edi,4), %edx
    mull %edx
    addl %esi, %edi
    addl iloczyn(,%edi,4), %eax
    movl %eax, iloczyn(,%edi,4)
    incl %edi
    adcl iloczyn(,%edi,4), %edx
    adcl $0, %ecx
    addl %ebx, %edx
    adcl $0, %ecx
    movl %ecx, %ebx
    movl %edx, iloczyn(,%edi,4)
    subl %esi, %edi
    jmp petla_w

koniec_pw:
    incl %esi
    jmp petla_z

koniec:
    movl $1, %eax
    movl $0, %ebx
    int $0x80
    
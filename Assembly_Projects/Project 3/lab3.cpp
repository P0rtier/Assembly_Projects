#include<time.h>
#include<fstream>
#include<iostream>
#include<stdlib.h>
#include<stdio.h>
using namespace std;

//definicje stałych / zmiennych

clock_t startTick , stopTick;
double timeSIMD_ADDITION ,timeSIMD_SUBTRACTION, timeSIMD_MULTIPLICATION, timeSIMD_DIVISON = 0;
double timeSISD_ADDITION ,timeSISD_SUBTRACTION, timeSISD_MULTIPLICATION, timeSISD_DIVISON = 0;

const unsigned int sizeOfVectors = 2048;
const unsigned int repeatsNumber = 10;

struct vector{
    float a1, a2, a3, a4;
};

vector *v1 = new vector[sizeOfVectors];
vector *v2 = new vector[sizeOfVectors];

//Wyniki działań:
vector addR_SIMD[sizeOfVectors];
vector subR_SIMD[sizeOfVectors];
vector mulR_SIMD[sizeOfVectors];
vector divR_SIMD[sizeOfVectors];
vector addR_SISD[sizeOfVectors];
vector subR_SISD[sizeOfVectors];
vector mulR_SISD[sizeOfVectors];
vector divR_SISD[sizeOfVectors];

fstream file_SIMD;
fstream file_SISD;

//Funkcje programu


//Randomizacja wektorów
void vectorRandomize(){
    srand(time(NULL));
    int i = 0;
    while(i<sizeOfVectors){
        // Randomizacja Wektora v1
        v1[i].a1 = (float)(rand()%1000+1)/20;
        v1[i].a2 = (float)(rand()%1000+1)/20;
        v1[i].a3 = (float)(rand()%1000+1)/20;
        v1[i].a4 = (float)(rand()%1000+1)/20;
        // Randomizacja Wektora v2
        v2[i].a1 = (float)(rand()%1000+1)/20;
        v2[i].a2 = (float)(rand()%1000+1)/20;
        v2[i].a3 = (float)(rand()%1000+1)/20;
        v2[i].a4 = (float)(rand()%1000+1)/20;
        i+=1;
    }
}

//Operacje arytmetyczne:
//SIMD:

void addVector_SIMD(){
    startTick = clock();// Pobudzenie zegara i zapis t0 do zmiennej
    for(int i = 0; i<repeatsNumber; i++)
        for(int j = 0; j<sizeOfVectors;j++){
            //Wykorzystanie metod Inline Assembly dla C / C++
            //Wykorzystanie mechanizmów SSE takich jak dyrektywy
            //operacyjne oraz rejestry rozszerzenia SSE
            asm("movaps %1, %%xmm0;" //Przeniesienie pierwszego elementu zapamiętanego (sekcja input) do rejestru %xmm0 
                "movaps %2, %%xmm1;" //Przeniesienie drugiego elementu zapamiętanego (sekcja input) do rejestru %xmm1
                "addps %%xmm1, %%xmm0;" //Wykonanie operacji arytmetycznej oraz zapamiętanie wyniku w rejestrze %xmm0
                "movaps %%xmm0, %0;" //przeniesienie wyniku do określonego adresu wyjściowego
                : "=m" (addR_SIMD[j]) //Sekcja output
                //definicja wyjśia dla ciągu instrukcji zawartych wewnątrz asm()
                : "m" (v1[j]), "m" (v2[j]) //Sekcja input
                //definicja wejść pamięciowych dla operacji arytmetycznych
            );
        }
    stopTick = clock(); //zatrzymanie zegara i zapis t1 do zmiennej
    double temp = (double) (stopTick - startTick) / CLOCKS_PER_SEC; //zmienna pomocnicza zapamiętująca różnicę czasu pomiędzy t0 a t1 w [s]
    timeSIMD_ADDITION = temp / repeatsNumber; // zapamiętanie uśrednionego wyniku
}

void subVector_SIMD(){
    startTick = clock();
    for(int i = 0; i<repeatsNumber; i++)
        for(int j = 0; j<sizeOfVectors;j++){
            asm("movaps %1, %%xmm0;"
                "movaps %2, %%xmm1;"
                "subps %%xmm1, %%xmm0;"
                "movaps %%xmm0, %0;" 
                : "=m"(subR_SIMD[j])
                : "m" (v1[j]), "m" (v2[j])
            );
        }
    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSIMD_SUBTRACTION = temp / repeatsNumber;
}

//Mnozemie w SIMD
void mulVector_SIMD(){
    startTick = clock();
    for(int i = 0; i<repeatsNumber; i++)
        for(int j = 0; j<sizeOfVectors;j++){
            asm("movaps %1, %%xmm0;"
                "movaps %2, %%xmm1;"
                "mulps %%xmm1, %%xmm0;"
                "movaps %%xmm0, %0;" 
                : "=m" (mulR_SIMD[j])
                : "m" (v1[j]), "m" (v2[j])
            );
        }
    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSIMD_MULTIPLICATION = temp / repeatsNumber;
}

void divVector_SIMD(){
    startTick = clock();
    for(int i = 0; i<repeatsNumber; i++)
        for(int j = 0; j<sizeOfVectors;j++){
            asm(
                "movaps %1, %%xmm0;"
                "movaps %2, %%xmm1;"
                "divps %%xmm1, %%xmm0;"
                "movaps %%xmm0, %0;" 
            :    "=m"(divR_SIMD[j])
            :   "m" (v1[j]), "m" (v2[j]) 
            );
        }
    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSIMD_DIVISON = temp / repeatsNumber;
}

//SISD:

void addVector_SISD(struct vector* result){
    startTick = clock();
    for(int i=0;i<repeatsNumber;i++)
        for(int j=0;j<sizeOfVectors;j++){           
            asm(
            // dodawanie dla części a1
            "fld %4;" //pobranie pierwszego elementu z pamięci wyszczególnionego w sekscji input
            "fadd %8;" //szybkie dodanie jednakowych elementów wektora do siebie (v1.a1 [+ | - | * | /] v2.a1)
            "fstp %0;" // zapis wyniku do pierwszego adresu wyspecjalziowanego w sekscji output

            // dodawanie dla części a2
            "fld %5;" //pobranie drugiego elementu z pamięci wyszczególnionego w sekscji input
            "fadd %9;" //szybkie dodanie jednakowych elementów wektora do siebie (v1.a2 [+ | - | * | /] v2.a2)
            "fstp %1;" // zapis wyniku do drugiego adresu wyspecjalziowanego w sekscji output

            //dodawanie dla części a3
            "fld %6;" //pobranie tzeciego elementu z pamięci wyszczególnionego w sekscji input
            "fadd %10;" //szybkie dodanie jednakowych elementów wektora do siebie (v1.a3 [+ | - | * | /] v2.a3)
            "fstp %2;" // zapis wyniku do trzeciego adresu wyspecjalziowanego w sekscji output

            //dodawanie dla części a4
            "fld %7;" //pobranie czwartego elementu z pamięci wyszczególnionego w sekscji input
            "fadd %11;" //szybkie dodanie jednakowych elementów wektora do siebie (v1.a4 [+ | - | * | /] v2.a4)
            "fstp %3;" // zapis wyniku do czwartego adresu wyspecjalziowanego w sekscji output

            : //Sekcja output
            "=m"(result[j].a1),
            "=m"(result[j].a2),
            "=m"(result[j].a3),
            "=m"(result[j].a4)

            : //Sekcja input
            "m"(v1[i].a1),
            "m"(v1[i].a2),
            "m"(v1[i].a3),
            "m"(v1[i].a4),
            "m"(v2[i].a1),
            "m"(v2[i].a2),
            "m"(v2[i].a3),
            "m"(v2[i].a4)
            );
        }

    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSISD_ADDITION = temp / repeatsNumber;
}

void subVector_SISD(struct vector* result){
    startTick = clock();
    for(int i=0;i<repeatsNumber;i++)
        for(int j=0;j<sizeOfVectors;j++){ 
            asm(
            // dodawanie dla części a1
            "fld %4;"
            "fsub %8;"
            "fstp %0;"

            // dodawanie dla części a2
            "fld %5;"
            "fsub %9;"
            "fstp %1;"

            //dodawanie dla części a2
            "fld %6;"
            "fsub %10;"
            "fstp %2;"

            //dodawanie dla części a4
            "fld %7;"
            "fsub %11;"
            "fstp %3;"

            : 
            "=m"(result[j].a1),
            "=m"(result[j].a2),
            "=m"(result[j].a3),
            "=m"(result[j].a4)

            : "m"(v1[i].a1),
            "m"(v1[i].a2),
            "m"(v1[i].a3),
            "m"(v1[i].a4),
            "m"(v2[i].a1),
            "m"(v2[i].a2),
            "m"(v2[i].a3),
            "m"(v2[i].a4)
            );
        }
    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSISD_SUBTRACTION = temp / repeatsNumber;
}

void mulVector_SISD(struct vector* result){
    startTick = clock();
    for(int i=0;i<repeatsNumber;i++)
        for(int j=0;j<sizeOfVectors;j++){
            asm(
            // dodawanie dla części a1
            "fld %4;"
            "fmul %8;"
            "fstp %0;"

            // dodawanie dla części a2
            "fld %5;"
            "fmul %9;"
            "fstp %1;"

            //dodawanie dla części a2
            "fld %6;"
            "fmul %10;"
            "fstp %2;"

            //dodawanie dla części a4
            "fld %7;"
            "fmul %11;"
            "fstp %3;"

            : 
            "=m"(result[j].a1),
            "=m"(result[j].a2),
            "=m"(result[j].a3),
            "=m"(result[j].a4)

            : "m"(v1[i].a1),
            "m"(v1[i].a2),
            "m"(v1[i].a3),
            "m"(v1[i].a4),
            "m"(v2[i].a1),
            "m"(v2[i].a2),
            "m"(v2[i].a3),
            "m"(v2[i].a4)
            );
        }
    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSISD_MULTIPLICATION = temp / repeatsNumber;
}

void divVector_SISD(struct vector* result){
    startTick = clock();
    for(int i=0;i<repeatsNumber;i++)
        for(int j=0;j<sizeOfVectors;j++){
            asm(
            // dodawanie dla części a1
            "fld %4;"
            "fdiv %8;"
            "fstp %0;"

            // dodawanie dla części a2
            "fld %5;"
            "fdiv %9;"
            "fstp %1;"

            //dodawanie dla części a2
            "fld %6;"
            "fdiv %10;"
            "fstp %2;"

            //dodawanie dla części a4
            "fld %7;"
            "fdiv %11;"
            "fstp %3;"

            : 
            "=m"(result[j].a1),
            "=m"(result[j].a2),
            "=m"(result[j].a3),
            "=m"(result[j].a4)

            : "m"(v1[i].a1),
            "m"(v1[i].a2),
            "m"(v1[i].a3),
            "m"(v1[i].a4),
            "m"(v2[i].a1),
            "m"(v2[i].a2),
            "m"(v2[i].a3),
            "m"(v2[i].a4)
            );
        }
    stopTick = clock();
    double temp = (double) (stopTick - startTick)/CLOCKS_PER_SEC;
    timeSISD_DIVISON = temp / repeatsNumber;
}

void sisd_ops(){

    addVector_SISD(&addR_SISD[0]);
    subVector_SISD(&subR_SISD[0]);
    mulVector_SISD(&mulR_SISD[0]);
    divVector_SISD(&divR_SISD[0]);
}


void simd_fileWriter(){
    file_SIMD.open("Wyniki_SIMD.txt", ios::out);
    if(!file_SIMD.good())
        cout<<"\nBlad tworzenia pliku Wyniki_SIMD.txt!\n";
    else{
        file_SIMD<<"Typ obliczen: SIMD\n"
        << "Liczba liczb : " << sizeOfVectors << endl
        << "Sredni czas [s]:\n"
        <<"+ "<<fixed<<timeSIMD_ADDITION<<endl
        <<"- "<<fixed<<timeSIMD_SUBTRACTION<<endl
        <<"* "<<fixed<<timeSIMD_MULTIPLICATION<<endl
        <<"/ "<<fixed<<timeSIMD_DIVISON<<endl;

        file_SIMD.close();
    }
}

void sisd_fileWriter(){
    file_SISD.open("Wyniki_SISD.txt", ios::out);
    if(!file_SISD.good())
        cout<<"\nBlad tworzenia pliku Wyniki_SISD.txt!\n";
    else{
        file_SISD<<"Typ obliczen: SISD\n"
        << "Liczba liczb : " << sizeOfVectors << endl
        << "Sredni czas [s]:\n"
        <<"+ "<<fixed<<timeSISD_ADDITION<<endl
        <<"- "<<fixed<<timeSISD_SUBTRACTION<<endl
        <<"* "<<fixed<<timeSISD_MULTIPLICATION<<endl
        <<"/ "<<fixed<<timeSISD_DIVISON<<endl;

        file_SISD.close();
    }
}

int main(){
    vectorRandomize();

    // Operacje dla SIMD:
    addVector_SIMD();
    subVector_SIMD();
    mulVector_SIMD();
    divVector_SIMD();
    simd_fileWriter();
    
    //operacje dla SISD:
    sisd_ops();
    sisd_fileWriter();
}

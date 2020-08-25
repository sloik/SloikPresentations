#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

/*
 
 Data Race
 
 Warunki do powstania: 
    - chociaz 2 watki dziela ten sam fragment pamieci np. zmienna
    - chociaz 1 z nich zmienia wartosc tej zmiennej
 
 */

void zdeponuj(int kwota, int *konto) {
    *konto += kwota;
}


int main(int argc, const char * argv[]) {
    
    int status = 0; // wspoldzielony zasob
    
    
    std::vector<std::thread> watki; // trzymamy watki tutaj
    
    for (int i = 0; i < 1000; ++i) {
        
//         zdeponuj(100, &status);
//         zdeponuj(-100, &status);

        
        // dodajemy lambdy z praca do wykonania na watku
        watki.emplace_back([&] {

            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // szczypta losowosci

            zdeponuj(100, &status);

            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // dwie szczypty

            zdeponuj(-100, &status);
        });
    }
    
    // laczymy wszystkie wystartowane watki
    for (auto &t : watki) { t.join(); }
    
    std::cout << "Stan konta po: " << status << std::endl << std::endl;
    
    return 0;
}

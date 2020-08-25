#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>
#include <mutex>
#include <ctime>

/*
 * Mutex.
 */

void zdeponuj(int kwota, int *konto) {
    *konto += kwota;
}

int main(int argc, const char * argv[]) {
    
    int status = 0; // wspoldzielony zasob
    
    std::vector<std::thread> watki; // trzymamy watki tutaj
    
    std::mutex _mutex;
    
    time_t start;
    time (&start);
    
    for (int i = 0; i < 10000; ++i) {
        
        // dodajemy lambdy z praca do wykonania na watku
        watki.emplace_back([&] {
            
            _mutex.lock(); // -- start krytycznej sekcji kodu ---
            
            zdeponuj(100, &status);

            _mutex.unlock(); // -- stop krytycznej sekcji kodu --
            
            
            // wyobrazmy sobie ze tutaj wykonuje sie inna praca ale nie korzystajaca
            // ze wspolnego zasobu
            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // szczypta losowosci

            
            _mutex.lock(); // -- start krytycznej sekcji kodu ---
            
            zdeponuj(-100, &status);
            
            _mutex.unlock(); // -- stop krytycznej sekcji kodu --
        });
    }
    
    // laczymy wszystkie wystartowane watki
    for (auto &t : watki) { t.join(); }
    
    
    std::cout << "         Czas: " << difftime(std::time(NULL), start) << std::endl;
    std::cout << "Stan konta po: " << status << std::endl << std::endl;
    
    return 0;
}

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

void setNewBalance(int ammount, int *pBalance) {
    *pBalance += ammount;
}

int main(int argc, const char * argv[]) {
    
    int balance = 0; // współdzielony zasób
    
    std::vector<std::thread> threads; // trzymamy wątki tutaj
    
    std::mutex _mutex;
    
    time_t start;
    time (&start);
    
    for (int i = 0; i < 10000; ++i) {
        
        // dodajemy lambdy z pracą do wykonania na wątku
        threads.emplace_back([&] {
            
            _mutex.lock(); // -- start krytycznej sekcji kodu ---
            
            setNewBalance(100, &balance);

            _mutex.unlock(); // -- stop krytycznej sekcji kodu --
            
            
            // wyobraźmy sobie że tutaj wykonuje się inna praca ale nie korzystająca
            // ze wspólnego zasobu
            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // szczypta losowości

            
            _mutex.lock(); // -- start krytycznej sekcji kodu ---
            
            setNewBalance(-100, &balance);
            
            _mutex.unlock(); // -- stop krytycznej sekcji kodu --
        });
    }
    
    // łączymy wszystkie wystartowane wątki
    for (auto &thread : threads) { thread.join(); }
    
    
    std::cout << "         Czas: " << difftime(std::time(NULL), start) << std::endl;
    std::cout << "Stan konta po: " << balance << std::endl << std::endl;
    
    return 0;
}

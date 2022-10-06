#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

/*
 
 Data Race
 
 Warunki do powstania:
    - chociaż 2 wątki dzielą ten sam fragment pamięci np. zmienna
    - chociaż 1 z nich zmienia wartość tej zmiennej
 
 */

void setNewBalance(int ammount, int *pBalance) {
    *pBalance += ammount;
}


int main(int argc, const char * argv[]) {
    
    int balance = 0; // współdzielony zasób

    std::vector<std::thread> threads; // trzymamy wątki tutaj
    
    for (int i = 0; i < 1000; ++i) {
        
        // dodajemy lambdy z pracą do wykonania na wątku
        threads.emplace_back([&] {

            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // szczypta losowości

            setNewBalance(100, &balance);

            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // dwie szczypty

            setNewBalance(-100, &balance);
        });
    }
    
    // łączymy wszystkie wystartowane wątki
    for (auto &thread : threads) { thread.join(); }
    
    std::cout << "Stan konta po: " << balance << std::endl << std::endl;
    
    return 0;
}

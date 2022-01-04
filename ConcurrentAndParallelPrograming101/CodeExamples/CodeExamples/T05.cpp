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

void setNewBalance(int ammount, int *pBalance) {
    *pBalance += ammount;
}


int main(int argc, const char * argv[]) {
    
    int balance = 0; // wspoldzielony zasob

    std::vector<std::thread> threads; // trzymamy watki tutaj
    
    for (int i = 0; i < 1000; ++i) {
        
        // dodajemy lambdy z praca do wykonania na watku
        threads.emplace_back([&] {

            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // szczypta losowosci

            setNewBalance(100, &balance);

            std::this_thread::sleep_for(std::chrono::milliseconds(random()%100)); // dwie szczypty

            setNewBalance(-100, &balance);
        });
    }
    
    // laczymy wszystkie wystartowane watki
    for (auto &thread : threads) { thread.join(); }
    
    std::cout << "Stan konta po: " << balance << std::endl << std::endl;
    
    return 0;
}

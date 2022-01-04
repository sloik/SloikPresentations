#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

int main(int argc, const char * argv[]) {

    std::vector<std::thread> threads; // trzymamy watki tutaj
    
    for (int i = 0; i < 10; ++i) {
        
        // dodajemy lambdy z praca do wykonania na watku
        threads.emplace_back([i] {
            // usypiamy watek na chwilunie
            std::this_thread::sleep_for(std::chrono::milliseconds(100 * i));
            
            // zadanie jakie chcemy wykonac
            auto message = std::string(5, *std::to_string(i).c_str()); // 11111 etc.
            std::cout << message << std::endl;
            
        });
        
    }
    
    // laczymy wszystkie wystartowane watki
    for (auto &thread : threads) { thread.join(); }
    
    return 0;
}

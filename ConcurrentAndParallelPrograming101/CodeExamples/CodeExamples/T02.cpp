#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

int main(int argc, const char * argv[]) {

    std::vector<std::thread> threads; // trzymamy wątki tutaj
    
    for (int i = 0; i < 10; ++i) {
        
        // dodajemy lambdy z pracą do wykonania na wątku
        threads.emplace_back([i] {
            // usypiamy wątek na chwilunię
            std::this_thread::sleep_for(std::chrono::milliseconds(100 * i));
            
            // zadanie jakie chcemy wykonać
            auto message = std::string(5, *std::to_string(i).c_str()); // 11111 etc.
            std::cout << message << std::endl;
            
        });
        
    }
    
    // łączymy wszystkie wystartowane wątki
    for (auto &thread : threads) { thread.join(); }
    
    return 0;
}

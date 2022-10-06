#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

/*
    Co się stanie gdy zmienna w "bloku" zostanie złapana przez referencję?

    Hint: Współdzielony stan to zło!
 */


int main(int argc, const char * argv[]) {

    std::vector<std::thread> threads; // trzymamy wątki tutaj
    
    for (int i = 0; i < 9; ++i) {
        
        // dodajemy lambdy z pracą do wykonania na wątku
        threads.emplace_back([&i]{ // <-- referencja do licznika / [i] <-- złpałoby kopie
            
            // usypiamy wątek na chwilunię
            std::this_thread::sleep_for(std::chrono::milliseconds(10 * i));
            
            // zadanie jakie chcemy wykonać
            auto message = std::string(5, *std::to_string(i).c_str()); // 11111 etc.
            std::cout << message << std::endl;
            
        });
        
    }
    
    // łączymy wszystkie wystartowane wątki
    for (auto &thread : threads) { thread.join(); }
    
    return 0;
}


/*
    Wszystkie wątki widzą tą samą wartość zmiennej "i" gdyż jest złapana przez referencje.
*/

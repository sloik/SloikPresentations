#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

/*
 * Zobaczmy teraz co się stanie gdy do utworzenia wątku wykorzystamy funkcję pomocniczą.
 */

std::vector<std::thread> createThreads() {
    
    std::vector<std::thread> functionThreads;
    
    for (int i = 0; i < 20; ++i) {
        
        // dodajemy lambdy z pracą do wykonania na wątku
        functionThreads.emplace_back([&]{ // co się stanie jak złapiemy zmienną przez referencję
            // usypiamy wątek na chwilunię
            std::this_thread::sleep_for(std::chrono::milliseconds(10 * i));
            
            // zadanie jakie chcemy wykonać
            std::cout << "z wątku: " << i << std::endl;
        });
    }
    
    return functionThreads;
}


int main(int argc, const char * argv[]) {

    std::vector<std::thread> threads = createThreads();
        
    // łączymy wszystkie wystartowane wątki
    for (auto &thread : threads) { thread.join(); }
    
    return 0;
}


/*
 
 W czasie tworzenia wątku łapiemy referencję, która żyje na stosie. W momencie
 gdy funkcja wraca to wszystko co było w tamtym miejscu jest nadpisane kolejnymi
 wywołaniami. Natomiast dalej mamy zachowaną referencję do tamtego adresu.
 
 Programowanie wielowątkowe jest jak fizyka kwantowa.
 
*/

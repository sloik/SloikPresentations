#include <iostream>
#include <thread>
#include <vector>
#include <string>
#include <chrono>

/*
 * Zobaczmy teraz co się stanie gdy do utworzenia wątku wykorzystamy funkcję pomocniczą.
 */

std::vector<std::thread> generujWatki() {
    
    std::vector<std::thread> watki;
    
    for (int i = 0; i < 20; ++i) {
        
        // dodajemy lambdy z praca do wykonania na watku
        watki.emplace_back([&]{ // co sie stanie jak zlapiemy zmienna przez referencje
            // usypiamy watek na chwilunie
            std::this_thread::sleep_for(std::chrono::milliseconds(10 * i));
            
            // zadanie jakie chcemy wykonac
            std::cout << "z watku: " << i << std::endl;
        });
    }
    
    return watki;
}


int main(int argc, const char * argv[]) {

    std::vector<std::thread> watki = generujWatki();
        
    // laczymy wszystkie wystartowane watki
    for (auto &t : watki) { t.join(); }
    
    return 0;
}


/*
 
 W czasie tworzenia wątku łapiemy referencje która żyje na stosie. W momencie
 gdy funkcja wraca to wszystko co było w tamtym miejscu jest nadpisane kolejnymi
 wywołaniami. Natomiast dalej mamy zachowaną referencję do tamtego adresu.
 
 Programowanie wielowatkowe jest jak fizyka kwantowa.
 
*/

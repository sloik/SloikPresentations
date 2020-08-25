#include <iostream>
#include <thread>


void watek1() {
    std::cout << "1111111111111111111111111111111111111111\n";
}

void watek2() {
    std::cout << "2222222222222222222222222222222222222222\n";
}

int main(int argc, const char * argv[]) {

    // Tworzymy nowy watek
    std::thread t1(watek1); // w tym momencie zostal utworozny nowy watek 
    std::thread t2(watek2); // i tutaj tez!
    
    // Wypisujemy z glownego watku
    std::cout << "0000000000000000000000000000000000000000\n";

    
    t1.join();
    t2.join();
    
    return 0;
}

#include <iostream>
#include <thread>


void thread1() {
    std::cout << "1111111111111111111111111111111111111111\n";
}

void thread2() {
    std::cout << "2222222222222222222222222222222222222222\n";
}

///
/// Kolejność wypisywanych komunikatów jest nie deterministyczna.
/// Wystarczy uruchomić przykład kilka razy.
///
int main(int argc, const char * argv[]) {

    // Tworzymy nowy wątek
    std::thread t1(thread1); // w tym momencie został utworzony nowy wątek
    std::thread t2(thread2); // i tutaj też!
    
    // Wypisujemy z wątku
    std::cout << "0000000000000000000000000000000000000000\n";

    std::cout << "Waiting for end\n";

    t1.join();
    t2.join();

    std::cout << "Done\n";


    return 0;
}

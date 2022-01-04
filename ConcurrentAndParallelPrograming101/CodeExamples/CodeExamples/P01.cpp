/*
 Process
 */

#include <stdio.h>
#include <unistd.h>
#include <iostream>

int main(int argc, const char * argv[]) {
    
    std::cout << "Rodzic:      getpid -> " << ::getpid() << " (parent -> " << ::getppid() << ")" << std::endl << std::endl;

    // N- -- "ujemne" gdy wystapil blad
    // 0  -- proces potomny
    // N+ -- ID procesu potomnego do wykorzystania przez proces rodzica
    pid_t pid = fork();
    
    // error
    if (pid < 0) {
        perror("Nie udalo sie wywolac fork()");
        exit(-1);
    }
    
    // proces potomny
    if (0 == pid) {
        std::cout << "Dziecko:    ForkPID -> " << pid       << std::endl;
        std::cout << "Dziecko:     GetPid -> " << getpid()  << std::endl;
        std::cout << "Dziecko:  RodzicPID -> " << getppid() << std::endl;
        
        sleep(20);
        _exit(0);
    }
    // rodzic
    else {
        std::cout << "Rodzic: PID dziecka -> " << pid << std::endl << std::endl;
        
        // czekamy w nieskonczonosc az wszystkie procesy sie zakoncza
        wait(0);
    }
    
    
    std::cout << "Rodzic: po robocie :)" << std::endl;
    return 0;
}

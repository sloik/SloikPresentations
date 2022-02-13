//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Queues
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


//: **Dispatch Queue** jak nazwa wskazuje jest kolejką. Dodajemy do niej bloki operacji które są wykonywane serialnie (jeden za drugim) w kolejności First In First Out. **Serial queue** wywołuje tylko jeden blok na raz. Natomiast można mieć kilka takich kolejek i wtedy z perspektywy tych bloków kilka na raz będzie jednocześnie wykonywanych. **Concurrent queue** woła blok również w kolejności FIFO ale nie czeka na jego zakończenie zanim wywoła kolejny w kolejce. Wszystkie zadania/bloki dorzucone do kolejki wykonują sie na innym wątku niż watek UI-owy tzw. **główny wątek**.

//: ## Tworzenie Kolejki Seryjnej
//: Zaletą takiej kolejki jest to, że synchronizuje nam dostęp do współdzielonego zasobu. Gwarantując, że w danym czasie tylko jeden wątek z niego korzysta.

let serialQueue1 = DispatchQueue.init(label: "Seryjna Kolejka1")
let serialQueue2 = DispatchQueue.init(label: "Seryjna Kolejka2")



//: ## Tworzenie Kolejki "Równoległej"

let concurrentQueue = DispatchQueue.init(label: "Równoległa Kolejka", attributes: .concurrent)


//: System dostarcza nam juz kolejki równoległe (konkretnie 5) z których możemy korzystać. [Dokumentacja](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW5)

let systemQueue = DispatchQueue.global(qos: .background)

//: ## Dodawanie Zadań
//: Zadania możemy dodawać bezpośrednio do kolejek.

xtimeBlock("Dodawanie Zadań 1") {
    
    print("Przed Dodaniem Zadań")
    
    // "As an optimization, this function invokes the block on the current thread when possible."
    serialQueue1.sync {
        sleep(1)
        print("111111111111 -> Główny wątek: \(Thread.isMainThread)")
    }

    serialQueue2.async {
        sleep(1)
        print("222222222222 -> Główny wątek: \(Thread.isMainThread)")
    }
    
    concurrentQueue.async {
        sleep(1)
        print("333333333333 -> Główny wątek: \(Thread.isMainThread)")
    }
    
    systemQueue.async {
        sleep(1)
        print("444444444444 -> Główny wątek: \(Thread.isMainThread)")
    }
    
    print("Po Dodaniu Zadań\n")
}


//: Zobaczmy co się stanie jak dodamy więcej zadań

xtimeBlock("Dużo zadań seryjnych (sync)") {
 
    for i in 0...10 {
        print("tick...")
        
        // przed wywołaniem kolejnego bloku zaczeka na zakończenie poprzedniego
        serialQueue1.sync {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }
    }
}

xtimeBlock("Dużo zadań seryjnych (async)") {
    
    for i in 0...10 {
        print("tick...")
        
        serialQueue1.async {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }
    }
}

xtimeBlock("Raz jedna seryjna raz druga seryjna (async)") {
    
    for i in 0...10 {
        if i % 2 == 0 {
            serialQueue1.async {
                sleep(1)
                let message = String.init(repeating: "\(i)", count: 20)
                print(message + " -> Główny wątek: \(Thread.isMainThread)")
            }
        } else {
            serialQueue2.async {
                sleep(1)
                let message = String.init(repeating: "\(i)", count: 20)
                print(message + " -> Główny wątek: \(Thread.isMainThread)")
            }
        }
    }
}

xtimeBlock("Dużo zadań równoległych (sync)") {
    
    for i in 0...10 {
        print("tick...")
        
        // przed wywołaniem kolejnego bloku zaczeka na zakończenie poprzedniego
        concurrentQueue.sync {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }
    }
}

xtimeBlock("Dużo zadań równoległych (async)") {
    
    for i in 0...20 {
        
        concurrentQueue.async {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }
    }
}

//: ## DispatchWorkItem
//: Zadanie które chcemy wykonać możemy opakować w ładniusie obiekty. Jako bonusik zadanie wystartujemy z nowego wątku ale zakończymy na głównym.

let taskToDo  = DispatchWorkItem {
    print("Jest Robota  -> Główny wątek: \(Thread.isMainThread)");
}

xtimeBlock("Wołamy Główny Wątek") {
    
    Thread.init {
        print("Z innego wątku...  -> Główny wątek: \(Thread.isMainThread)");
        DispatchQueue.main.async(execute: taskToDo)
        
        }.start()
}

//: [Wstecz](@previous) | [Następna strona](@next)

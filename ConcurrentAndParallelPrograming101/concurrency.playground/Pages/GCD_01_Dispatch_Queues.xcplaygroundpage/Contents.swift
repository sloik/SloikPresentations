//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Queues
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


//: **Dispatch Queue** jak nazwa wskazuje jest kolejka. Dodajemy do niej bloki operacji które są wykonywane serialnie (jeden za drugim) w kolejności First In First Out. **Serial queue** wywołuje tylko jeden blok na raz. Natomiast można mieć kilka takich kolejek i wtedy z perspektywy tych bloków kilka na raz będzie jednocześnie wykonywanych. **Concurrent queue** woła blok również w kolejności FIFO ale nie czeka na jego zakończenie zanim wywoła kolejny w kolejce. Wszystkie zadania/bloki dorzucone do kolejki wykonują sie na innym wątku niż watek UI-owy tzw. **główny wątek**.

//: ## Tworzenie Kolejki Seryjnej
//: Zaletą takiej kolejki jest to, że synchronizuje nam dostęp do współdzielonego zasobu. Gwarantując, że w danym czasie tylko jeden wątek z niego korzysta.

let seryjnaKolejka1 = DispatchQueue.init(label: "Seryjne Kolejka1")
let seryjnaKolejka2 = DispatchQueue.init(label: "Seryjne Kolejka2")



//: ## Tworzenie Kolejki "Równoległej"

let rownoleglaKolejka = DispatchQueue.init(label: "Rownolegla Kolejka", attributes: .concurrent)


//: System dostarcza nam juz kolejki równoległe (konkretnie 5) z których możemy korzystać. [Dokumentacja](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW5)

let systemowaKolejka = DispatchQueue.global(qos: .background)

//: ## Dodawanie Zadań
//: Zadania możemy dodawać bezpośrednio do kolejek.

xtimeBlock("Dodawanie Zadan 1") {
    
    print("Przed Dodaniem Zadan")
    
    // "As an optimization, this function invokes the block on the current thread when possible."
    seryjnaKolejka1.sync {
        sleep(1)
        print("111111111111 -> Glowny watek: \(Thread.isMainThread)")
    }

    seryjnaKolejka2.async {
        sleep(1)
        print("222222222222 -> Glowny watek: \(Thread.isMainThread)")
    }
    
    rownoleglaKolejka.async {
        sleep(1)
        print("333333333333 -> Glowny watek: \(Thread.isMainThread)")
    }
    
    systemowaKolejka.async {
        sleep(1)
        print("444444444444 -> Glowny watek: \(Thread.isMainThread)")
    }
    
    print("Po Dodaniu Zadan\n")
}


//: Zobaczmy co sie stanie jak dodamy wiecej zadan

xtimeBlock("Duzo zadan seryjnych (sync)") {
 
    for i in 0...10 {
        print("tick...")
        
        // przed wywolaniem kolejnego bloku zaczeka na zakonczenie porpzedniego
        seryjnaKolejka1.sync {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Glowny watek: \(Thread.isMainThread)")
        }
    }
}

xtimeBlock("Duzo zadan seryjnych (async)") {
    
    for i in 0...10 {
        print("tick...")
        
        seryjnaKolejka1.async {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Glowny watek: \(Thread.isMainThread)")
        }
    }
}

xtimeBlock("Raz jedna seryjna raz druga seryjna (async)") {
    
    for i in 0...10 {
        if i % 2 == 0 {
            seryjnaKolejka1.async {
                sleep(1)
                let message = String.init(repeating: "\(i)", count: 20)
                print(message + " -> Glowny watek: \(Thread.isMainThread)")
            }
        } else {
            seryjnaKolejka2.async {
                sleep(1)
                let message = String.init(repeating: "\(i)", count: 20)
                print(message + " -> Glowny watek: \(Thread.isMainThread)")
            }
        }
    }
}

xtimeBlock("Duzo zadan rownoleglych (sync)") {
    
    for i in 0...10 {
        print("tick...")
        
        // przed wywolaniem kolejnego bloku zaczeka na zakonczenie porpzedniego
        rownoleglaKolejka.sync {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Glowny watek: \(Thread.isMainThread)")
        }
    }
}

xtimeBlock("Duzo zadan rownoleglych (async)") {
    
    for i in 0...20 {
        
        rownoleglaKolejka.async {
            sleep(1)
            let message = String.init(repeating: "\(i)", count: 20)
            print(message + " -> Glowny watek: \(Thread.isMainThread)")
        }
    }    
}

//: ## DispatchWorkItem
//: Zadanie które chcemy wykonać możemy opakować w ladniusie obiekty. Jako bonusik zadanie wystartujemy z nowego wątku ale zakończymy na głównym.

let zadanieDoWykonania  = DispatchWorkItem {
    print("Jest Robota  -> Glowny watek: \(Thread.isMainThread)");
}

xtimeBlock("Wołamy Główny Wątek") {
    
    Thread.init {
        print("Z innego wątku...  -> Glowny watek: \(Thread.isMainThread)");
        DispatchQueue.main.async(execute: zadanieDoWykonania)
        
        }.start()
}

//: [Wstecz](@previous) | [Następna strona](@next)

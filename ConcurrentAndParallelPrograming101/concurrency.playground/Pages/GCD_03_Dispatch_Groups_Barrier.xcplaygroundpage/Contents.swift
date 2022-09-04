//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Barrier
 */

import Foundation
import PlaygroundSupport


PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 Korzystanie ze wspólnego zasobu z wielu różnych wątków może być nieco skomplikowane. Tak długo jeżeli wszystkie wątki tylko czytają z danego zasobu to nie ma żadnego problemu. W dowolnym momencie takie czytanie może zostać przerwane i wznowione a odczytana wartość zawsze będzie prawidłowa. Problem powstaje gdy chociaż jeden z wątków chciały coś w tym czasie zapisać do tego zasobu. 

 */


xtimeBlock("Problem") {
    
    let groupA = DispatchGroup()

    let address = Address(street: "Szkolna", number: "13");
    print(address.full)
    
    address.change(street: "Mokotowska", number: "1")
    print(address.full)
    
    let concurrentQueue = DispatchQueue(label: "Równoległa Kolejka", attributes: .concurrent)

    
    for (street, number) in [("Szkolna", "13"), ("Sokołowska", "9"), ("Mokotowska", "1")] {
        concurrentQueue.async(group: groupA) {
            address.change(street: street, number: number)
            print("Zmieniono na: \(address.full)")
        }
    }
    
    groupA.wait()
    print("\nOstatecznie: \(address.full)")
}


//: **Bariera** działa tak że pozwala dokończyć działanie wszystkim zdaniom, które już wystartowały. Jednocześnie blokuje wystartowanie zadań, które zostały dodane po barierze. De facto zmieniając kolejkę ze współbieżnej na seryjną (na czas wykonania tego zadania).
//: Wprowadzając odrobinę kreatywnej księgowości możemy zaimplementować takiego zwierza który pozwala czytać z wielu wątków a gdy nadchodzi czas zapisu to wszystkie inne wątki są blokowane. [Multiple Readers Single Writer](https://www.objc.io/issues/2-concurrency/low-level-concurrency-apis/#multiple-readers-single-writer)

xtimeBlock("Rozwiązanie") {
    
    class SafeAddress: Address {
        let isolation = DispatchQueue(label: "Izolatka", attributes: .concurrent)
        
        
        override open func change(street: String, number: String) {
//: Tworzenie Bariery
            isolation.async(flags: .barrier) { 
                super.change(street: street, number: number)
            }
        }
        
        override open var full: String {
            var result = ""
            
            isolation.sync { // musimy użyc synchronicznego wywołania
                result = super.full
                print("Wywołane z wątku: \(Thread.current)")
            }
            
            return result
        }
    }
    
    let groupA = DispatchGroup()
    
    let address = SafeAddress(street: "Szkolna", number: "13");
    
    let concurrentQueue = DispatchQueue(label: "Równoległa Kolejka", attributes: .concurrent)
    
    for (street, number) in [("Szkolna", "13"), ("Sokołowska", "9"), ("Gnojna", "32"), ("Wiejska", "42"), ("Mokotowska", "1")] {
        concurrentQueue.async(group: groupA) {
            address.change(street: street, number: number)
            print("Zmieniono na: \(address.full) - - - > Wywołane z wątku: \(Thread.current)")
        }
    }
    
    groupA.wait()
    print("\nOstatecznie: \(address.full)")
}

/*:

# Deadlock

_Zakleszczenie_ najczęściej występuje w sytuacji gdy dwa programy lub wątki współdzielą zasób i skutecznie uniemożliwiają sobie dostanie się do tego zasobu.

 W świecie iOS może się to objawiać przez zlecenie pracy synchronicznie na tą samą kolekle

 */

xtimeBlock("🔒 Deadlock") {

    let serialQueue = DispatchQueue(label: "lekko.techno.serial.deadlock")

    print("Adding work to queue...")
    serialQueue.sync {

        print("Starting work on a task... and dispatching to the sirial queue synchronously")

        serialQueue.sync {
            print("We should start work but...")
        }
    }

    print("😎 all is done")
}

/*:

 Aplikacja crashuje. Dzieje się tak dlatego, że dajemy zadanie do wykoania i czekamy na nie. Wewnątrz tego zadania ponownie dodajemy zadanie i na nie czekamy. Jednak to drugie zadanie nie może wystartować ponieważ to pierwsze nie skończyło. Mamy tu impas.

 Sytuacja nie zmienia się nawet gdy pierwsze wywołanie jest asynchroniczne:
 */

xtimeBlock("🤿 Deadlock with async") {

    let serialQueue = DispatchQueue(label: "lekko.techno.serial.deadlock")

    print("Adding work to queue...")
    serialQueue.async { // <-- this is now async

        print("Starting work on a task... and dispatching to the sirial queue synchronously")

        serialQueue.sync {
            print("😥😭 We should start work but...") // this never prints
        }
    }

    // TODO for the reader:
    // What will happen if you add more task on a serial queue?
    // hint: add a sleep so the code above will have a chance to run

    print("😎 all is done")
}

/*:

 Na pierwszy rzut oka jest lepiej ale problem jest dokladnie ten sam i dlatego nie widać wewnętrznego printa.

 */

//: [Wstecz](@previous) | [Następna strona](@next)

print("🏁")


//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Barrier
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Korzystanie ze wspólnego zasobu z wielu różnych wątków może być nieco skomplikowane. Tak długo jeżeli wszystkie wątki tylko czytają z danego zasobu to nie ma żadnego problemu. W dowolnym momencie takie czytanie może zostać przerwane i wznowione a odczytana wartość zawsze będzie prawidłowa. Problem powstaje gdy chociaż jeden z wątków chciały coś w tym czasie zapisać do tego zasobu. 

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
            isolation.async(flags: .barrier) { // nowa składnia uwaga!
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

PlaygroundPage.current.finishExecution()


//: [Wstecz](@previous) | [Następna strona](@next)

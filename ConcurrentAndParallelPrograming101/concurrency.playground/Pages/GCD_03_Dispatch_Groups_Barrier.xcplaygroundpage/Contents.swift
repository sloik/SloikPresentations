//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Barrier
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Korzystanie ze wspólnego zasobu z wielu różnych wątków może być nieco skomplikowane. Tak długo jeżeli wszystkie wątki tylko czytają z danego zasobu to nie ma żadnego problemu. W dowolnym momencie takie czytanie może zostać przerwane i wznowione a odczytana wartość zawsze będzie prawidłowa. Problem powstaje gdy chociaż jeden z wątków chciały coś w tym czasie zapisać do tego zasobu. 

xtimeBlock("Problem") {
    
    let grupaA = DispatchGroup()

    let adres = Adres(ulica: "Szkolna", numer: "13");
    print(adres.pelen)
    
    adres.zmien(ulica: "Mokotowska", numer: "1")
    print(adres.pelen)
    
    let rownoleglaKolejka = DispatchQueue(label: "Rownolegla Kolejka", attributes: .concurrent)

    
    for (ulica, numer) in [("Szkolna", "13"), ("Sokołowska", "9"), ("Mokotowska", "1")] {
        rownoleglaKolejka.async(group: grupaA) {
            adres.zmien(ulica: ulica, numer: numer)
            print("Zmieniono na: \(adres.pelen)")
        }
    }
    
    grupaA.wait()
    print("\nOstatecznie: \(adres.pelen)")
}


//: **Bariera** działa tak że pozwala dokończyć działanie wszystkim zdaniom, które już wystartowały. Jednocześnie blokuje wystartowanie zadań, które zostały dodane po barierze. De facto zmieniając kolejkę ze współbieżnej na seryjną (na czas wykonania tego zadania). 
//: Wprowadzając odrobinę kreatywnej księgowości możemy zaimplementować takiego zwierza który pozwala czytać z wielu wątków a gdy nadchodzi czas zapisu to wszystkie inne wątki są blokowane. [Multiple Readers Single Writer](https://www.objc.io/issues/2-concurrency/low-level-concurrency-apis/#multiple-readers-single-writer)

xtimeBlock("Rozwiazanie") {
    
    class BezpiecznyAdres: Adres {
        let izolatka = DispatchQueue(label: "Izolatka", attributes: .concurrent)
        
        
        override open func zmien(ulica: String, numer: String) {
//: Tworzenie Bariery
            izolatka.async(flags: .barrier) { // nowa składnia uwaga!
                super.zmien(ulica: ulica, numer: numer)
            }
        }
        
        override open var pelen: String {
            var wynik = ""
            
            izolatka.sync { // musimy użyc synchronicznego wywolania
                wynik = super.pelen
                print("Wywolane z watku: \(Thread.current)")
            }
            
            return wynik
        }
    }
    
    let grupaA = DispatchGroup()
    
    let adres = BezpiecznyAdres(ulica: "Szkolna", numer: "13");
    
    let rownoleglaKolejka = DispatchQueue(label: "Rownolegla Kolejka", attributes: .concurrent)
    
    for (ulica, numer) in [("Szkolna", "13"), ("Sokołowska", "9"), ("Gnojna", "32"), ("Wiejska", "42"), ("Mokotowska", "1")] {
        rownoleglaKolejka.async(group: grupaA) {
            adres.zmien(ulica: ulica, numer: numer)
            print("Zmieniono na: \(adres.pelen) - - - > Wywolane z watku: \(Thread.current)")
        }
    }
    
    grupaA.wait()
    print("\nOstatecznie: \(adres.pelen)")
}

PlaygroundPage.current.finishExecution()


//: [Wstecz](@previous) | [Następna strona](@next)

//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Raz i Po / dispatch_once / dispatch_after
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 # Dispatch Once

 Czasami chcemy aby jakiś kod przez czas życia programu wykonał się dokładnie raz. W Swift 3 metoda dispatch_once() znana ze wcześniejszych wersji jak i z ObjC przestała istnieć.

* The free function dispatch_once is no longer available in Swift. In Swift, you can use lazily initialized globals or static properties and get the same thread-safety and called-once guarantees as dispatch_once provided.* [Dokumentacja](https://swift.org/migration-guide/)

Dziś, zgodnie z [dokumentacją](https://docs.swift.org/swift-book/LanguageGuide/Properties.html#ID264). Używa się do tego zmiennych statycznych, które są `lazy` oraz `thread safe`.

Uruchom przykład:
 */


xtimeBlock("🏓 Once") {
    
    class OnlyOnce {
        static var once: Void = {
            print("Akcja")
        }()
        
        func wtf() {
            OnlyOnce.once
        }
    }

    print("Creating an instance...")
    OnlyOnce()

    print("Before loop...")
    let threads: [Thread] = (1...50_000)
        .map { _ in
            Thread {
                randomDelay(maxDuration: 0.2)

                OnlyOnce.once
                OnlyOnce().wtf()
            }
        }

    threads
        .forEach { $0.start() }
}

/*:

Klasa `OnlyOnce` posiada statyczną zmienną `once`. Jej wartość to wynik działania closure wypisującego text do konsoli. Metoda `wtf` służy do zwrócenia wartości, która została przypisana do zmiennej statycznej.

Przykład zaczyna się od utworzenia instancji. Jak widać po wyniku w konsoli w tym momencie blok inicjalizujący zmienna się nie uruchomił. Jest to zgodne z dokumentacją, która mówi, że property na typie są leniwe bez potrzeby anotacji.

W dalszej części jest tworzone 50k wątków! Jednak metoda została wykonana raz.

# Dispatch After

 Gdy chcemy aby jakieś zadanie zostało wykonane po pewnym czasie to GCD nam to umożliwia. Wystarczy podać czas po jakim ma się zadanie wykonać i gotowe:
 */


xtimeBlock("⏱ after") {
    
    let start = Date()
    print("Start: \(start)")
    
    DispatchQueue
        .main
        .asyncAfter(deadline: .now() + .seconds(2)) {
            print("😎 Wywołane po czasie: \(Date().timeIntervalSince(start))")
        }
    
    print("Stop: \(Date().timeIntervalSince(start))")
    
}


//: [Wstecz](@previous)

print("🏁")


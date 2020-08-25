//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Raz i Po / dispatch_once / dispatch_after
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: ## Dispatch Once
//: Czasami chcemy aby jakiś kod przez czas życia programu wykonał się dokładnie raz. W Swift 3 metoda dispatch_once() znana ze wcześniejszych wersji jak i z ObjC przestała istnieć.
//:
//: *The free function dispatch_once is no longer available in Swift. In Swift, you can use lazily initialized globals or static properties and get the same thread-safety and called-once guarantees as dispatch_once provided.* [Dokumentacja](https://swift.org/migration-guide/)

xtimeBlock("Tylko Raz") {
    
    class TylkoRaz {
        static var raz: () = {
            print("Akcja")
        }()
        
        func wtf() {
            TylkoRaz.raz
        }
    }
    
    for _ in 1...50000 {
        Thread.init{
            TylkoRaz.raz
        }

        TylkoRaz.init().wtf()
    }
}

//: ## Dispatch After
//: Gdy chcemy aby jakieś zadanie zostało wykonane po pewnym czasie to GCD nam to umożliwia. Co bardzo fajne składnia się nieco uzywilizowała w Swift 3.

xtimeBlock("Po") {
    
    let start = Date()
    print("Start: \(start)")
    
    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
        print("😎 Wywołane po czasie: \(Date().timeIntervalSince(start))")
    }
    
    print("Stop: \(Date().timeIntervalSince(start))")
    
}


//: [Wstecz](@previous)

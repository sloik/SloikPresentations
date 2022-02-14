//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Anulowanie Operacji
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

typealias Consumer<T> = (T) -> ()

final class Adding: Operation {
    
    private(set) var numberA: Int
    private(set) var numberB: Int
    private var result: Int = 0
    var finalResult: Consumer<Int>?
    
    init(a: Int, b: Int) {
        numberA = a
        numberB = b
        
        super.init()
    }
    
    override func main() {
        
        print("Dodawanie: W main()")

        sleep(2)

        if isCancelled == true {
            return
        }
        
        print("Dodawanie: Po sprawdzeniu isCancelled")

        sleep(2)
        
        print("Dodawanie: Po drzemce")

        result = numberA + numberB
        finalResult?(result)
    }
}

timeBlock("🥮 Po prostu biegniemy") {
    let op1 = Adding(a: 2, b: 4)
    
    op1.finalResult = { result in
        print("Po prostu biegniemy: \(result)")
    }
    
    op1.start()
}

//: Nic nadzwyczajnego. Dokładnie to czego byśmy się spodziewali. Liczby zostały dodane a w bloku dostajemy sume.

//: Zobaczmy teraz co się stanie jak takie zadanie zostanie natychmiast anulowane.

timeBlock("⚡️ Anulujemy przed wystartowaniem...") {
    let op1 = Adding(a: 2, b: 8)
    
    op1.finalResult = { result in
        print("Natychmiast anulujemy: \(result)")
    }
    
    op1.cancel()
    op1.start()
//    op1.cancel() // nic nie da ponieważ zadanie wykonuje sie synchronicznie
}

//: Wywołanie metody **cancel** zmienia tylko wartośc property **isCanceled**.
//:
//: Aby anulowanie operacji zadziałało parawidłowo (czyli faktycznie ja anulowało) to musimy w implementacji metody main (lub w tej metodzie gdzie lwia część pracy się wykonuje) sprawdzać stan wlaściwości **isCancelled**. Jeżeli mamy więcej takich części które wykonują dużo pracy to możemy (powinniśmy) dodać takie sprawdzenie przed (lub w trakcie zbierając cząstkowe wyniki) jej rozpoczęciem.


//: [Wstecz](@previous) | [Następna strona](@next)

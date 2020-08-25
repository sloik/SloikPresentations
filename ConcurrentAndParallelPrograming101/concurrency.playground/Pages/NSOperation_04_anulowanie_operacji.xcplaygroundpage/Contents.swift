//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Anulowanie Operacji
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class Dodawanie: Operation {
    
    var liczbaA: Int
    var liczbaB: Int
    private var wynik: Int = 0
    var wynikResult: ((Int) -> ())?
    
    init(a: Int, b: Int) {
        liczbaA = a
        liczbaB = b
        
        super.init()
    }
    
    override func main() {
        
        print("Dodawanie: W main()")

        if isCancelled == true {
            return
        }
        
        print("Dodawanie: Po sprawdzeniu isCancelled")

        sleep(2)
        
        print("Dodawanie: Po drzemce")

        wynik = liczbaA + liczbaB
        wynikResult?(wynik)
    }
}

xtimeBlock("Po prostu biegniemy") {
    let op1 = Dodawanie.init(a: 2, b: 4)
    
    op1.wynikResult = { wynik in
        print("Po prostu biegniemy: \(wynik)")
    }
    
    op1.start()
}

//: Nic nadzwyczajnego. Dokładnie to czego bysmy się spodziewali. Liczby zostały dodane a w bloku dostajemy sume.

//: Zobaczmy teraz co się stanie jak takie zadanie zostanie natychmiast anulowane.

xtimeBlock("Natychmiast anulujemy") {
    let op1 = Dodawanie.init(a: 2, b: 8)
    
    op1.wynikResult = { wynik in
        print("Natychmiast anulujemy: \(wynik)")
    }
    
    op1.cancel()
    op1.start()
//    op1.cancel() // nic nie da ponieważ zadanie wykonuje sie synchronicznie
}

//: Wywołanie metody **cancel** zmienia tylko wartośc property **isCanceled**.
//:
//: Aby anulowanie operacji zadziałało parawidłowo (czyli faktycznie ja anulowało) to musimy w implementacji metody main (lub w tej metodzie gdzie lwia czesc pracy sie wykonuje) sprawdzac stan wlasciwowsci **isCancelled**. Jezeli mamy więcej takich części które wykonują dużo pracy to możemy (powinniśmy) dodać takie sprawdzenie przed (lub w trakcie zbierając cząstkowe wyniki) jej rozpoczęciem.


//: [Wstecz](@previous) | [Następna strona](@next)

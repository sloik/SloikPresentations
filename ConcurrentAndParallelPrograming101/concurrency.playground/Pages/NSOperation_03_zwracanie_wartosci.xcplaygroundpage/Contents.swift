//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Zwracanie Wartosci
 */
import Foundation

class Dodawanie: Operation {
    
    var liczbaA: Int
    var liczbaB: Int
    var wynik: Int = 0
    var wynikResult: ((_ wynik: Int) -> ())?
    
    init(a: Int, b: Int) {
        liczbaA = a
        liczbaB = b
        
        super.init()
    }
    
    override func main() {
        sleep(1)
        wynik = liczbaA + liczbaB
        
        wynikResult?(wynik)
    }
}

xtimeBlock("Prosta Operacja Dodawania") {
    let op1 = Dodawanie.init(a: 2, b: 4)
    let op2 = Dodawanie.init(a: 3, b: 6)
    
    op1.wynikResult = { wynik in
        print("Wynikiem operacji jest: \(wynik)")
    }
    
    op1.completionBlock = { [unowned op1] in
        print("CompletionBlock: \(op1.wynik)")
    }
    
    op1.start()
    op2.start()
    
    print("Wynikami operacji są: \(op1.wynik), \(op2.wynik)")
}

//: Nie ma żadnych ograniczeń co do sposobu zwracania wartości z wykonywanej operacji. Tak więc możemy korzystać ze notyfikacji, KVO, delegacji czy też jak w przykładzie bloków i zmiennej która będzie przechowywać wynik.


//: [Wstecz](@previous) | [Następna strona](@next)

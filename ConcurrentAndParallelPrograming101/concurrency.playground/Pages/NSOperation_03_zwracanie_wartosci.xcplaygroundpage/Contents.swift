//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Zwracanie Wartosci
 */
import Foundation

typealias Consumer<T> = (T) -> ()

final class Adding: Operation {
    
    private (set) var numberA: Int
    private (set) var numberB: Int
    private (set) var  result: Int = 0

    var finalResult: Consumer<Int>?
    
    init(a: Int, b: Int) {
        numberA = a
        numberB = b
        
        super.init()
    }
    
    override func main() {
        sleep(1)
        result = numberA + numberB
        
        finalResult?(result)
    }
}

timeBlock("🌖 Prosta Operacja Dodawania") {
    let op1 = Adding.init(a: 2, b: 4)
    let op2 = Adding.init(a: 3, b: 6)
    
    op1.finalResult = { result in
        print("Wynikiem operacji jest: \(result)")
    }
    
    op1.completionBlock = { [unowned op1] in
        print("CompletionBlock: \(op1.result)")
    }
    
    op1.start()
    op2.start()
    
    print("Wynikami operacji są: \(op1.result), \(op2.result)")
}

//: Nie ma żadnych ograniczeń co do sposobu zwracania wartości z wykonywanej operacji. Tak więc możemy korzystać z notyfikacji, KVO, delegacji czy też jak w przykładzie bloków i zmiennej która będzie przechowywać wynik.


//: [Wstecz](@previous) | [Następna strona](@next)

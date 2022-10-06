//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Przekazywanie Wartości Między Operacjami
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Dodajemy protokól.

import Foundation

protocol HotPotato {
    var counter: Int? { get }
}

final class RecipeStep: Operation, HotPotato {
    let step: String
    
    var counter: Int? // operacja implementuje protokół
    
    init(step: String) {
        self.step = step
        super.init()
    }
    
    override func main() {
        sleep(1)
        
        // Każda operacja ma właściwość **dependencies** w której są zawarte zależne operacje.
        if let passedValue = dependencies
            .filter( { $0 is HotPotato } ) // sprawdzamy czy zależność implementuje protokół
            .first as? HotPotato {         // bierzemy pierwszą ktora to robi (będzie jedna bo sami ją ustawiamy)
            counter = passedValue.counter
        }
        if let counter = counter {
            self.counter! += 1
            print("\(counter) \(step) -> Główny wątek: \(Thread.isMainThread)");
        }
        else {
            self.counter = 1 // nie było wartości to już jest
            print("\(step) -> Główny wątek: \(Thread.isMainThread)");
        }
    }
}

final class Baking: AsyncOperation, HotPotato {
    
    var counter: Int? // operacja implementuje protokół
    
    override func main() {
        let thread = Thread {
            sleep(5)
            
            // Każda operacja ma właściwość **dependencies** w której są zawarte zależne operacje.
            if let passedValue = self.dependencies
                .filter( {$0 is HotPotato} ) // sprawdzamy czy zależność implementuje protokół
                .first as? HotPotato {       // bierzemy pierwszą ktora to robi (będzie jedna bo sami ją ustawiamy)
                self.counter = passedValue.counter
            }
            
            print("❤️‍🔥 Ciasto upieczone -> Główny wątek: \(Thread.isMainThread)")
            
            if let _ = self.counter {
                self.counter! += 1
            }
            
            self.state = .Finished
        }
        
        thread.start()
    }
}

//: Tworzymy Zadania

let addEggs    = RecipeStep(step: "🥚 dodaj jajka")
addEggs.counter = 1

let addMilk    = RecipeStep(step: "🥛 dodaj mleko")
let addFlour   = RecipeStep(step: "🌾 dodaj mąkę")
let mixDough   = RecipeStep(step: "🥄 mieszaj ciasto")
let bake       = Baking()
let serveCake  = RecipeStep(step: "🥮 podaj ciasto")

let allOperations = [serveCake, bake, mixDough, addFlour, addMilk, addEggs]

precedencegroup Additive {
    associativity: left
}
infix operator |> : Additive
func |>(lhs: Operation, rhs: Operation) -> Operation {
    rhs.addDependency(lhs)
    return rhs
}

addEggs |> addMilk |> addFlour |> mixDough |> bake |> serveCake

let queue = OperationQueue()
queue.maxConcurrentOperationCount = 1 // sprawdź co się stanie jak zwiększysz tą liczbę

queue.addOperations(allOperations, waitUntilFinished: false)

//: [Wstecz](@previous) | [Następna strona](@next)

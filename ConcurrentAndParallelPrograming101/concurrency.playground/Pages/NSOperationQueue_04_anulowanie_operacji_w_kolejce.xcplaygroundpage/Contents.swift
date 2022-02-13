//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Anulowanie Operacji W Kolejce
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class RecipeStep: Operation {
    let step: String
    
    init(step: String) {
        self.step = step
        super.init()
    }
    
    override func main() {
        sleep(1)
        
        if isCancelled {
            return
        }
        
        print("\(step) -> Główny wątek: \(Thread.isMainThread)");
    }
}

class Baking: AsyncOperation {
    override func main() {
        let thread = Thread.init {
            if self.isCancelled {
                self.state = .Finished
                return
            }
            
            sleep(5)
            print("🔥 Ciasto upieczone -> Główny wątek: \(Thread.isMainThread)")
            
            self.state = .Finished
        }
        
        thread.start()
    }
}

//: Tworzymy Zadania

let addEggs    = RecipeStep.init(step: "dodaj jajka")
let addMilk    = RecipeStep.init(step: "dodaj mleko")
let addFlour   = RecipeStep.init(step: "dodaj mąkę")
let mixDough   = RecipeStep.init(step: "mieszaj ciasto")
let bake       = Baking()
let serveCake   = RecipeStep.init(step: "🍰 PODAJ CIASTO")

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
queue.maxConcurrentOperationCount = 5

queue.addOperations(allOperations, waitUntilFinished: false)

sleep(3) // dajemy czas aby coś się wykonało na kolejce

//: Tak anulujemy pojedyncze zadanie. Powinno wyglądać znajomo już do tego czasu.
bake.cancel()

//: Tak anulujemy wszystkie zadania w kolejce.
queue.cancelAllOperations()

//: [Wstecz](@previous) | [Następna strona](@next)

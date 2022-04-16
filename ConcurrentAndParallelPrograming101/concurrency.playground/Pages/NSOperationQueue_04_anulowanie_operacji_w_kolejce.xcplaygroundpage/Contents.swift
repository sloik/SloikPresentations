//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Anulowanie Operacji W Kolejce
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

final class RecipeStep: Operation {
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
        
        print("\(step)");
    }
}

final class Baking: AsyncOperation {
    override func main() {
        let thread = Thread.init {
            if self.isCancelled {
                self.state = .Finished
                return
            }
            
            sleep(5)
            print("🔥 Ciasto upieczone")
            
            self.state = .Finished
        }
        
        thread.start()
    }
}

//: Tworzymy Zadania

let addEggs    = RecipeStep(step: "🥚 dodaj jajka")
let addMilk    = RecipeStep(step: "🥛 dodaj mleko")
let addFlour   = RecipeStep(step: "🌾 dodaj mąkę")
let mixDough   = RecipeStep(step: "🥄 mieszaj ciasto")
let bake       = Baking()
let serveCake  = RecipeStep(step: "🥮 PODAJ CIASTO")

let allOperations = [serveCake, bake, mixDough, addFlour, addMilk, addEggs].shuffled()


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
bake.cancel() // anulowane zadanie nie blokuje kolejnego!

//: Tak anulujemy wszystkie zadania w kolejce.
queue.cancelAllOperations()

//: [Wstecz](@previous) | [Następna strona](@next)

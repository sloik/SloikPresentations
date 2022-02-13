//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Zależności
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Czasami zachodzi potrzeba aby jakieś zadanie wykonało się przed innym (w pierwszej kolejności musimy zmieszać ciasto a potem wsadzamy je do piekarnika). Korzystając z kolejek operacji możemy ustawić zależności pomiędzy jej poszczególnymi zadaniami. Co więcej przy odrobinie przebiegłości możemy też przekazywać wynik jednej operacji bezpośrednio do drugiej.

class RecipeStep: Operation {
    let step: String
    
    init(step: String) {
        self.step = step
        super.init()
    }
    
    override func main() {
        sleep(1)

        print("\(step) -> Główny wątek: \(Thread.isMainThread)");
    }
}

class Baking: AsyncOperation {
    override func main() {
        let thread = Thread.init {
            sleep(5)
            print("Ciasto upieczone -> Główny wątek: \(Thread.isMainThread)")
            
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
let serveCake  = RecipeStep.init(step: "podaj ciasto")
//: Dodajemy zależności
xtimeBlock("Definiowanie zależności \"ręcznie\"") {
    addMilk.addDependency(addEggs)
    addFlour.addDependency(addMilk)

//    mixDough.addDependency(addEggs)
//    mixDough.addDependency(addMilk)

    mixDough.addDependency(addFlour)
    bake.addDependency(mixDough)
    serveCake.addDependency(bake)
}
//: Można też na sterydach to zrobić...
precedencegroup Additive {
    associativity: left
}
infix operator |> : Additive
func |>(lhs: Operation, rhs: Operation) -> Operation {
    rhs.addDependency(lhs)
    return rhs
}

xtimeBlock("Zależności dodane własnym operatorem") {
     addEggs |> addMilk |> addFlour |> mixDough |> bake |> serveCake
}

let queue = OperationQueue()
queue.maxConcurrentOperationCount = 10 // mozna pobawic sie ilością

timeBlock("start wszystkich operacji") {
    
    let allOperations = [serveCake, bake, mixDough, addFlour, addMilk, addEggs]

    queue.addOperations(allOperations, waitUntilFinished: false)
}


//: [Wstecz](@previous) | [Następna strona](@next)

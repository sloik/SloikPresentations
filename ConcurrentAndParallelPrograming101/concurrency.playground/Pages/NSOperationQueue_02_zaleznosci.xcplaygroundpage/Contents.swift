//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Zależności
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Czasami zachodzi potrzeba aby jakieś zadanie wykonało się przed innym (w pierwszej kolejności musimy zmieszać ciasto a potem wsadzamy je do piekarnika). Korzystając z kolejek operacji możemy ustawić zależności pomiędzy jej poszczególnymi zadaniami. Co więcej przy odrobinie przebiegłości możemy też przekazywać wynik jednej operacji bezpośrednio do drugiej.

final class RecipeStep: Operation {
    let step: String
    
    init(step: String) {
        self.step = step
        super.init()
    }
    
    override func main() {
        let date = Date()

        print("🚀 \(step)", date, Thread.isMainThread)

        sleep(2)

        print("🏁 \(step)");
    }
}

final class Baking: AsyncOperation {
    override func main() {
        let thread = Thread {
            let date = Date()

            print("🚀 ❤️‍🔥...", date, Thread.isMainThread)

            sleep(5)
            print("🏁 ❤️‍🔥 Ciasto upieczone")
            
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
let serveCake  = RecipeStep(step: "🥮 podaj ciasto")
//: Dodajemy zależności
timeBlock("🧢 Definiowanie zależności \"ręcznie\"") {

    let someMagicValue: Bool = false

    if someMagicValue {
        addMilk.addDependency(addEggs)
        addFlour.addDependency(addMilk)
    } else {
        mixDough.addDependency(addEggs)
        mixDough.addDependency(addMilk)
    }

    mixDough.addDependency(addFlour)

    bake.addDependency(mixDough)
    serveCake.addDependency(bake)
}
//: Można też na sterydach to zrobić...
precedencegroup Additive {
    associativity: left
}

infix operator |> : Additive

@discardableResult func |>(lhs: Operation, rhs: Operation) -> Operation {
    rhs.addDependency(lhs)
    return rhs
}

xtimeBlock("🦏 Zależności dodane własnym operatorem") {
     addEggs |> addMilk |> addFlour |> mixDough |> bake |> serveCake
}

let queue = OperationQueue()
queue.maxConcurrentOperationCount = 10 // mozna pobawic sie ilością

timeBlock("🏃🏻‍♂️ start wszystkich operacji") {
    
    let allOperations = [serveCake, bake, mixDough, addFlour, addMilk, addEggs]

    queue.addOperations(allOperations, waitUntilFinished: false)
}


//: [Wstecz](@previous) | [Następna strona](@next)

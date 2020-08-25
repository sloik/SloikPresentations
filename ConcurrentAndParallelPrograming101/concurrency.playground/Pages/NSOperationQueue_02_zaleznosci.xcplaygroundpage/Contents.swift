//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Zależności
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Czasami zachodzi potrzeba aby jakieś zadanie wykonało się przed innym (w pierwszej kolejności musimy zmieszać ciasto a potem wsadzamy je do piekarnika). Korzystając z kolejek operacji możemy ustawić zależności po między jej poszczególnymi zadaniami. Co więcej przy odrobinie przebiegłości możemy też przekazywać wynik jednej operacji bezpośrednio do drugiej.

class PrzepisKrok: Operation {
    let krok:String
    
    init(krok: String) {
        self.krok = krok
        super.init()
    }
    
    override func main() {
        sleep(1)

        print("\(krok) -> Glowny watek: \(Thread.isMainThread)");
    }
}

class Pieczenie: AsyncOperation {
    override func main() {
        let watek = Thread.init {
            sleep(5)
            print("Ciasto upieczone -> Glowny watek: \(Thread.isMainThread)")
            
            self.state = .Finished
        }
        
        watek.start()
    }
}

//: Tworzymy Zadania
let dodajJajka    = PrzepisKrok.init(krok: "dodaj jajka")
let dodajMleko    = PrzepisKrok.init(krok: "dodaj mleko")
let dodajMake     = PrzepisKrok.init(krok: "dodaj make")
let mieszajCiasto = PrzepisKrok.init(krok: "mieszaj ciasto")
let piecz         = Pieczenie()
let podajCiasto   = PrzepisKrok.init(krok: "podaj ciasto")
//: Dodajemy zleżności
xtimeBlock("Definiowanie zaleznosci \"recznie\"") {
    dodajMleko.addDependency(dodajJajka)
    dodajMake.addDependency(dodajMleko)

//    mieszajCiasto.addDependency(dodajJajka)
//    mieszajCiasto.addDependency(dodajMleko)

    mieszajCiasto.addDependency(dodajMake)
    piecz.addDependency(mieszajCiasto)
    podajCiasto.addDependency(piecz)
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

xtimeBlock("Zaleznosci dodane wlasnym operatorem") {
     dodajJajka |> dodajMleko |> dodajMake |> mieszajCiasto |> piecz |> podajCiasto
}

let koljka = OperationQueue()
koljka.maxConcurrentOperationCount = 10 // mozna pobawic sie iloscia

timeBlock("start wszystkich operacji") {
    
    let wszystkieOperacje = [podajCiasto, piecz, mieszajCiasto, dodajMake, dodajMleko, dodajJajka]

    koljka.addOperations(wszystkieOperacje, waitUntilFinished: false)
}


//: [Wstecz](@previous) | [Następna strona](@next)

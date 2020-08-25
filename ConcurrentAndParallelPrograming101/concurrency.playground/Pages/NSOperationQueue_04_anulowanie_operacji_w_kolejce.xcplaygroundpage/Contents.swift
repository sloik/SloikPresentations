//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Anulowanie Operacji W Kolejce
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

class PrzepisKrok: Operation {
    let krok:String
    
    init(krok: String) {
        self.krok = krok
        super.init()
    }
    
    override func main() {
        sleep(1)
        
        if isCancelled {
            return
        }
        
        print("\(krok) -> Glowny watek: \(Thread.isMainThread)");
    }
}

class Pieczenie: AsyncOperation {
    override func main() {
        let watek = Thread.init {
            if self.isCancelled {
                self.state = .Finished
                return
            }
            
            sleep(5)
            print("🔥 Ciasto upieczone -> Glowny watek: \(Thread.isMainThread)")
            
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
let podajCiasto   = PrzepisKrok.init(krok: "🍰 PODAJ CIASTO")

let wszystkieOperacje = [podajCiasto, piecz, mieszajCiasto, dodajMake, dodajMleko, dodajJajka]


precedencegroup Additive {
    associativity: left
}
infix operator |> : Additive
func |>(lhs: Operation, rhs: Operation) -> Operation {
    rhs.addDependency(lhs)
    return rhs
}

dodajJajka |> dodajMleko |> dodajMake |> mieszajCiasto |> piecz |> podajCiasto

let kolejka = OperationQueue()
kolejka.maxConcurrentOperationCount = 5

kolejka.addOperations(wszystkieOperacje, waitUntilFinished: false)

sleep(3) // dajemy czas aby cos sie wykonalo na kolejce

//: Tak anulujemy pojedyncze zadanie. Powinno wygladac znajomo juz do tego czasu.
piecz.cancel()

//: Tak anulujemy wszystkie zadania w kolejce.
kolejka.cancelAllOperations()


//: [Wstecz](@previous) | [Następna strona](@next)

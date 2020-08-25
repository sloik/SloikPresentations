//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Przekazywanie Wartości Między Operacjami
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Dodajemy protokól.

protocol GoracyZiemniak {
    var licznik: Int? { get }
}

class PrzepisKrok: Operation, GoracyZiemniak {
    let krok:String
    
    var licznik: Int? // operacja implementuje protokol
    
    init(krok: String) {
        self.krok = krok
        super.init()
    }
    
    override func main() {
        sleep(1)
        
        // Każda operacja ma właściwość **dependencies** w której są zawarte zależne operacje.
        if let przekazanaWartosc = dependencies
            .filter({$0 is GoracyZiemniak}) // sprawdzamy czy zaleznosc implementuje protokol
            .first as? GoracyZiemniak {     // bierzemy pierwsza ktora to robi (wiemy ze bedzie jedna bo sami ja ustawiamy)
            licznik = przekazanaWartosc.licznik
        }
        
        if let licznik = licznik {
            self.licznik! += 1
            print("\(licznik) \(krok) -> Glowny watek: \(Thread.isMainThread)");
        }
        else {
            self.licznik = 1; // nie bylo wartosci to juz jest
            print("\(krok) -> Glowny watek: \(Thread.isMainThread)");
        }
    }
}

class Pieczenie: AsyncOperation, GoracyZiemniak {
    
    var licznik: Int? // operacja implementuje protokol
    
    override func main() {
        let watek = Thread.init {
            sleep(5)
            
            // Każda operacja ma właściwość **dependencies** w której są zawarte zależne operacje.
            if let przekazanaWartosc = self.dependencies
                .filter({$0 is GoracyZiemniak}) // sprawdzamy czy zaleznosc implementuje protokol
                .first as? GoracyZiemniak {     // bierzemy pierwsza ktora to robi (wiemy ze bedzie jedna bo sami ja ustawiamy)
                self.licznik = przekazanaWartosc.licznik
            }
            
            print("Ciasto upieczone -> Glowny watek: \(Thread.isMainThread)")
            
            if let _ = self.licznik {
                self.licznik! += 1
            }
            
            self.state = .Finished
        }
        
        watek.start()
    }
}

//: Tworzymy Zadania

let dodajJajka    = PrzepisKrok.init(krok: "dodaj jajka")
dodajJajka.licznik = 1

let dodajMleko    = PrzepisKrok.init(krok: "dodaj mleko")
let dodajMake     = PrzepisKrok.init(krok: "dodaj make")
let mieszajCiasto = PrzepisKrok.init(krok: "mieszaj ciasto")
let piecz         = Pieczenie()
let podajCiasto   = PrzepisKrok.init(krok: "podaj ciasto")

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

let koljka = OperationQueue()
koljka.maxConcurrentOperationCount = 1 // sprawdz co sie stanie jak zwiekszysz ta liczbe

koljka.addOperations(wszystkieOperacje, waitUntilFinished: false)


//: [Wstecz](@previous) | [Następna strona](@next)

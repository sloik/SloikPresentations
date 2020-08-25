//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Operation Queue - Tworzenie
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Koncepcyjnie możemy myśleć o **OperationQueue** jak o *liście zadań do wykonania*. Pewne zadania możemy wykonywać jednocześnie z innymi. Inne będziemy mogli wykonać tylko jeżeli wcześniej zakończyliśmy jeszcze jakieś inne zadanie. Możemy kogoś powiadomić o wykonaniu zadań jak również możemy dorzucać zadania i je anulować.
//: Z technicznego punktu widzenia NSOperationQueue jest instancją klasy NSOperationQueue, która umożliwia nam te rzeczy wpsomniane wczesniej.


let kolejka = OperationQueue()
kolejka.maxConcurrentOperationCount = 2; // pobawmy się nieco wartością tej zmiennej 1,2,5,15 etc.

//: Możemy dodawać zadania bezpośrednio do kolejki jako bloki bez konieczności tworzenia instancji NSOperacji. Zadania wykonują się natychmiast po dodaniu (oczywiście jeżeli kolejka na to pozwoli, jak nie to czekają na swoją kolej ;)).

xtimeBlock("Dodawanie blokow do kolejki") {
    kolejka.addOperation { sleep(2); print("Adam")   }
    kolejka.addOperation { sleep(2); print("Babie")  }
    kolejka.addOperation { sleep(2); print("Cebule") }
    kolejka.addOperation { sleep(2); print("Daje")   }
    
    kolejka.waitUntilAllOperationsAreFinished()
}

//: Jak widać możemy kontrolować ile zadań na raz się wykonuje. Co więcej przy ustawieniu max na 1 otrzymujemy kolejke seryjną w której zadania się wykonuje jedno za drugim w kolejności ich dodania.

//: ## Dodawanie NSOperacji

class ProstaOperacja: Operation {
    let wiadomosc:String
    
    init(wiadomosc: String) {
        self.wiadomosc = wiadomosc
        
        super.init()
    }
    
    override func main() {
        sleep(1)
        print("\(wiadomosc) -> Glowny watek: \(Thread.isMainThread)");
    }
}

//: Tworzymy operacje
let prostaOperacjaAdam   = ProstaOperacja.init(wiadomosc: "Adam")
let prostaOperacjaBabie  = ProstaOperacja.init(wiadomosc: "Babie")
let prostaOperacjaCebule = ProstaOperacja.init(wiadomosc: "Cebule")
let prostaOperacjaDaje   = ProstaOperacja.init(wiadomosc: "Daje")

//: Tworzymy kolejke
let kolejka2 = OperationQueue()
kolejka2.maxConcurrentOperationCount = 1

xtimeBlock("Dodane wlasne operacje") {
    kolejka2.addOperation(prostaOperacjaAdam)
    kolejka2.addOperation(prostaOperacjaBabie)
    kolejka2.addOperation(prostaOperacjaCebule)
    kolejka2.addOperation(prostaOperacjaDaje)

    kolejka2.waitUntilAllOperationsAreFinished()
}

//: ## Wywołanie Operacji Na Głównym Wątku
xtimeBlock("Wracamy do glownego watku") {
    
    OperationQueue.main.addOperation {
        print("Halo! Czy to główny wątek? Glowny watek: \(Thread.isMainThread)")
    }
}

//: [Wstecz](@previous) | [Następna strona](@next)

//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Operation Queue - Tworzenie
 */
import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Koncepcyjnie możemy myśleć o **OperationQueue** jak o *liście zadań do wykonania*. Pewne zadania możemy wykonywać jednocześnie z innymi. Inne będziemy mogli wykonać tylko jeżeli wcześniej zakończyliśmy jeszcze jakieś inne zadanie. Możemy kogoś powiadomić o wykonaniu zadań jak również możemy dorzucać zadania i je anulować.
//: Z technicznego punktu widzenia NSOperationQueue jest instancją klasy NSOperationQueue, która umożliwia nam te rzeczy wspomniane wczesniej.


let queue = OperationQueue()
queue.maxConcurrentOperationCount = 2 // pobawmy się nieco wartością tej zmiennej 1,2,5,15 etc.

//: Możemy dodawać zadania bezpośrednio do kolejki jako bloki bez konieczności tworzenia instancji NSOperacji. Zadania wykonują się natychmiast po dodaniu (oczywiście jeżeli kolejka na to pozwoli, jak nie to czekają na swoją kolej ;)).

timeBlock("🧤 Dodawanie bloków do kolejki") {
    queue.addOperation { sleep(2); print("Adam")   }
    queue.addOperation { sleep(2); print("Babie")  }
    queue.addOperation { sleep(2); print("Cebule") }
    queue.addOperation { sleep(2); print("Daje")   }
    
    queue.waitUntilAllOperationsAreFinished()
}

//: Jak widać możemy kontrolować ile zadań naraz się wykonuje. Co więcej przy ustawieniu max na 1 otrzymujemy kolejkę seryjną w której zadania się wykonuje jedno za drugim w kolejności ich dodania.

//: ## Dodawanie NSOperacji

final class SimpleOperation: Operation {
    let message: String
    
    init(message: String) {
        self.message = message
        
        super.init()
    }
    
    override func main() {
        sleep(1)
        print("\(message) -> Główny wątek: \(Thread.isMainThread)");
    }
}

//: Tworzymy operacje
let simpleOperationAdam   = SimpleOperation(message: "Adam")
let simpleOperationBabie  = SimpleOperation(message: "Babie")
let simpleOperationCebule = SimpleOperation(message: "Cebule")
let simpleOperationDaje   = SimpleOperation(message: "Daje")

//: Tworzymy kolejkę
let queue2 = OperationQueue()
queue2.maxConcurrentOperationCount = 1

timeBlock("💍 Dodane własne operacje") {
    queue2.addOperation(simpleOperationAdam)
    queue2.addOperation(simpleOperationBabie)
    queue2.addOperation(simpleOperationCebule)
    queue2.addOperation(simpleOperationDaje)

    queue2.waitUntilAllOperationsAreFinished()
}

//: ## Wywołanie Operacji Na Głównym Wątku
timeBlock("👘 Wracamy do głównego wątku") {
    
    OperationQueue.main.addOperation {
        print("Halo! Czy to główny wątek? Główny wątek: \(Thread.isMainThread)")
    }
}

//: [Wstecz](@previous) | [Następna strona](@next)

//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Groups
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 Sprawdzanie zakończenia pojedynczego tasku jest banalnie proste (wystarczy dodać taką informacje na koniec wrzuconego bloku i gotowe). Co w sytuacji gdy mamy tych zadań dużo i chcemy się dowiedzieć gdy wszystkie się zakończą? Całe szczęście z pomocą nadchodzą grupy :)

 ## Tworzymy Grupy

 */

let groupA = DispatchGroup()
let groupB = DispatchGroup()

/*:
 Potrzebujemy kolejek na których będziemy uruchamiać zadania
 */

let systemQueue = DispatchQueue.global(qos: .background)
let serialQueue = DispatchQueue(label: "lekko.techno.group.demo.1")

/*:
 ## Notyfikacja o Zakończeniu Wszystkich Zadań w Grupie

 Zadania w grupie mogą się znajdować w różnych kolejkach.

 */


xtimeBlock("Wszystkie Zadania Skończone") {
    
    systemQueue.async(group: groupA) {
        print("To żyje 1 -> Główny wątek: \(Thread.isMainThread)")
    }
    
    serialQueue.async(group: groupA) {
        sleep(3)
        print("To żyje 2 -> Główny wątek: \(Thread.isMainThread)")
    }
    
    groupA.notify(queue: DispatchQueue.main) {
        print("Na obu kolejkach robota skończona :) -> Główny wątek: \(Thread.isMainThread)")
    }
    
    print("\nPrzed czekaniem na grupe A")
    groupA.wait(timeout: DispatchTime.distantFuture)
    print("Po czekaniu na grupę A")
}

/*:

 ## Dispatch Group Enter / Leave

 Jeżeli używamy metod asynchronicznych to z punktu widzenia grupy zadanie się wykonało (doszło do końca wykonywanej funkcji). Chociaż tak na prawdę może oczekiwać np na odpowiedź z serwera lub zakończenie innego asynchronicznego zadania.

 */


xtimeBlock("Problem Przy Asynchronicznych Metodach") {
    
    systemQueue.async(group: groupA) {
        Asynchronous().checkWhatWillHappen {
            DispatchQueue.main.async {
                print("Robota Ogarnięta  -> Główny wątek: \(Thread.isMainThread)")
            }
        }
    }
    
    groupA.notify(queue: DispatchQueue.main) {
        print("Wszystkie zadania w grupie wykonane 💥")
    }
}

/*:
 Rozwiązaniem jest "ręczne" oznaczenie w którym momencie zadanie **wchodzi** do grupy i w którym **wychodzi**.
 */

xtimeBlock("Rozwiązanie Przy Asynchronicznych Metodach") {
    
    groupA.enter()
    systemQueue.async {
        Asynchronous().checkWhatWillHappen {
            DispatchQueue.main.async {
                print("Robota Ogarnięta  -> Główny wątek: \(Thread.isMainThread)")
            }
            
            groupA.leave()
        }
    }
    
    groupA.notify(queue: DispatchQueue.main) {
        print("Wszystkie zadania w grupie wykonane 😎")
    }
}

//: [Wstecz](@previous) | [Następna strona](@next)

print("🏁")

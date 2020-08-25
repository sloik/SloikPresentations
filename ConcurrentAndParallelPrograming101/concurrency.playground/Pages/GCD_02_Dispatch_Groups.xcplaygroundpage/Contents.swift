//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Groups
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//: Sprawdzanie zakończenia pojedyńczego tasku jest banalnie proste (wystarczy dodać taką informaje na koniec wrzuconego bloku i gotowe). Co w sytuacji gdy mamy tych zadań dużo i chcemy się dowiedzieć gdy wszystkie się zakończą? Całe szczęście z pomocą nadchodzą grupy :)
//: ## Tworzymy Grupe
let grupaA = DispatchGroup()

//: Świetnie nam idzie. Zrobmy jeszcze jedna.

let grupaB = DispatchGroup()

//: Potrzebujemy kolejki na ktorej bedziemy uruchamiac nazsze zadania
let systemowaKolejka = DispatchQueue.global(qos: .background)
let seryjnaKolejka   = DispatchQueue.init(label: "Seryjne Kolejka1")

//: ## Notyfikaca o Zakonczeniu Wszystkich Zadan w Grupie
//: Zadania w grupie moga się znajdować w roznych kolejkach.

xtimeBlock("Wszystkie Zadania Skonczone") {
    
    systemowaKolejka.async(group: grupaA) {
        print("To żyje 1 -> Glowny watek: \(Thread.isMainThread)")
    }
    
    seryjnaKolejka.async(group: grupaA) {
        sleep(3)
        print("To żyje 2 -> Glowny watek: \(Thread.isMainThread)")
    }
    
    grupaA.notify(queue: DispatchQueue.main) {
        print("Na obu kolejkach robota skonczona :) -> Glowny watek: \(Thread.isMainThread)")
    }
    
    print("\nPrzed czekaniem na grupe A")
    grupaA.wait(timeout: DispatchTime.distantFuture)
    print("Po czekaniu na grupe A")
}

//: Dispatch Group Enter / Leave
//: Jeżeli używamy metod asynchronicznych to z punktu widzenia grupy zadanie się wykonało (doszło do końca wykonywanej funkcji). Chociaż tak na prawdę może oczekiwać np na odpowiedź z serwera lub zakończenie innego asynchronicznego zadania.

xtimeBlock("Problem Przy Asynchronicznych Metodach") {
    
    systemowaKolejka.async(group: grupaA) {
        Asynchroniczny().zobaczCoSieStanie {
            DispatchQueue.main.async {
                print("Robota Ogarnieta  -> Glowny watek: \(Thread.isMainThread)")
            }
        }
    }
    
    grupaA.notify(queue: DispatchQueue.main) {
        print("Wszystkie zadania w grupie wykonane 💥")
    }
}

//: Rozwiązaniem jest "reczne" oznaczenie w którym momencie zadanie **wchodzi** do grupy i w którym **wychodzi**.
xtimeBlock("Rozwiazanie Przy Asynchronicznych Metodach") {
    
    grupaA.enter()
    systemowaKolejka.async {
        Asynchroniczny().zobaczCoSieStanie {
            DispatchQueue.main.async {
                print("Robota Ogarnieta  -> Glowny watek: \(Thread.isMainThread)")
            }
            
            grupaA.leave()
        }
    }
    
    grupaA.notify(queue: DispatchQueue.main) {
        print("Wszystkie zadania w grupie wykonane 😎")
    }
}

//: [Wstecz](@previous) | [Następna strona](@next)

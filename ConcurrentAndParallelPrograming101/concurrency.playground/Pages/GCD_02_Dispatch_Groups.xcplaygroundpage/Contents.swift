//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Groups
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 Sprawdzanie zakończenia pojedynczego taska jest banalnie proste (wystarczy dodać taką informacje na koniec wrzuconego bloku i gotowe). Co w sytuacji gdy mamy tych zadań dużo i chcemy się dowiedzieć gdy wszystkie się zakończą (przetwarzamy różne dane lub pobieramy na raz coś z kilku endpoint-ów)?

 Całe szczęście z pomocą nadchodzą grupy :)

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

 Dodając zadanie do kolejki możemy podać grupę do której należą. Zadania w grupie mogą się znajdować w różnych kolejkach i te kolejki mogą być różnego typu (serial, concurrent).

 Proces wygląda nastepująco:

 * dodajemy zadania do kolejek jednocześnie mówiąc do której grupy należą
 * opcjonalnie możemy dodać na grupie blok jaki ma się wykonać po wykonaniu wszystkich zadań z grupy
 * opcjonalnie czekamy synchronicznie aż wszystkie zadania się wykonają

 Nie ma wymogu aby najpierw dodawać zadania a potem definiować closure jaki ma być wykonany po zakończeniu zadań z grupy.

 Tak samo nie trzeba czekać synchronicznie jednak z jakiegoś powodu chcemy to robić. Tu życiowym przykładem jest dalszy bieg programu dopiero jak pobierzemy jakieś dane z `N` serwisów. Strzały mogą być wykonane równolegle i dopiero po ich zakończeniu chcemy je procesować.

 Poniżej przykład który robi te wszystkie rzeczy:

 */

xtimeBlock("👀 Obserwacja zadań") {
    
    systemQueue.async(group: groupA) {
        print("🖥 System Queue -> Główny wątek: \(Thread.isMainThread)")
    }
    
    serialQueue.async(group: groupA) {
        sleep(3)
        print("🕵🏻‍♂️ Serial Queue -> Główny wątek: \(Thread.isMainThread)")
    }

    groupA
        .notify(queue: DispatchQueue.global(qos:.utility)) {
            print("🏋️‍♂️ Na obu kolejkach robota skończona :) -> Główny wątek: \(Thread.isMainThread)")
        }

    print("\nPrzed czekaniem na grupe A")
    groupA.wait(timeout: DispatchTime.distantFuture)
    print("Po czekaniu na grupę A")
}

/*:

 Analizując wynik działania przykładu widać, że metoda dodająca notyfikację działa asynchronicznie. Do tego można do niej przekazać kolejkę na jakiej ma się wykonać przekazany closure.

 Jeżeli to możliwe to lepiej jest używać metody z notyfikacją. Dzięki temu nie blokujemy kolejki/wątku na którym jest uruchomione zadanie. Jeżeli już korzystamy z metody `wait` to warto dodać do niej `timeout` aby nie zablokować całkiem działania aplikacji.

 ## Dispatch Group Enter / Leave

 W przyrodzie występuje wiele API, które działają asynchronicznie. Najczęściej objawia się to tak, że wywołujemy metodę na jakieś instancji i jednym z jej argumentów jest closure, który ma być wykonany gdy praca się zakończy.

 Ponieważ taki kod jest asynchroniczny to z punktu widzenia grupy zadanie się wykonało. Chociaż tak na prawdę może oczekiwać np. na odpowiedź z serwera lub zakończenie innego asynchronicznego zadania.

 Zobaczmy to na przykładzie. Enumeracja `Asynchronous` posiada asynchroniczną metodę `checkWhatWillHappen` która po jakimś czasie wywołuje przekazany closure.
 */


xtimeBlock("🏈 Problem Przy Asynchronicznych Metodach") {
    
    systemQueue.async(group: groupA) {

        Asynchronous.checkWhatWillHappen {

            print("Zaraz przekażę wynik na główną kolejkę.")

            DispatchQueue.main.async {
                print("Robota Ogarnięta  -> Główny wątek: \(Thread.isMainThread)")
            }
        }

    }
    
    groupA.notify(queue: DispatchQueue.main) {
        print("Wszystkie zadania w grupie wykonane 😎")
    }
}

/*:

 Niestety kompilator ani framework nie ma wiedzy kiedy closure został wykonany. Z punktu widzenia grupy zadanie się skończyło w momencie dodania do asynchronicznie do globalnej kolejki.

 Rozwiązaniem jest "ręczne" oznaczenie w którym momencie zadanie **wchodzi** do grupy i w którym **wychodzi**. Współpracując w ten sposób z GCD mamy dokładnie to zachowanie jakie chcemy:
 */

xtimeBlock("🥁 Rozwiązanie Przy Asynchronicznych Metodach") {
    
    groupA.enter()

    systemQueue.async {

        Asynchronous.checkWhatWillHappen {
            print("Zaraz przekażę wynik na główną kolejkę.")
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

/*:

 Różnice można łatwo przegapić, ale chodzi o moment w którym widać text:

 > Wszystkie zadania w grupie wykonane 😎

 W przykładzie _problemowym_ jest on na samej górze co świadczy, że wywołany został za wcześnie. W przykładzie _poprawnym_ jest to ostatni text jaki się wypisuje. Czyli wykonany został w momencie jak cała praca została wykonana.

 Ten mechanizm możemy wykorzystać do zlecania wielu zadań i oczekiwaniu aż wszystkie się wykonają (np. asynchroniczne pobranie 20 obrazków itd.).

 # Linki

 * [YT - Swift Arcade - Grouping network calls like a boss - DispatchGroup🛤️](https://youtu.be/Juadc1NVLsg)

---

 [Wstecz](@previous) | [Następna strona](@next)
 */


print("🏁")

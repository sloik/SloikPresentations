//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Barrier
 */

import Foundation
import PlaygroundSupport


PlaygroundPage.current.needsIndefiniteExecution = true

/*:

 # Data Race - Wyścig

 Korzystanie ze wspólnego zasobu z wielu różnych wątków może być nieco skomplikowane. Tak długo jeżeli wszystkie wątki tylko czytają z danego zasobu to nie ma żadnego problemu. W dowolnym momencie takie czytanie może zostać przerwane i wznowione a odczytana wartość zawsze będzie prawidłowa. Problem powstaje gdy chociaż jeden z wątków chciały coś w tym czasie zapisać do tego zasobu.

 Do zilustrowania tego problemu użyję klasę `Address`. Jej zadaniem jest pomoc w zrozumieniu problemu a nie bycie wzorcową klasą przechowującą adresy.

 */

open class Address {
    private var street: String
    private var number: String

    public init(street: String, number: String) {
        self.street = street
        self.number = number
    }

    open func change(street: String, number: String) {
        randomDelay(maxDuration: 0.1)
        self.street = street
        randomDelay(maxDuration: 1)
        self.number = number
    }

    open var full: String {
        randomDelay(maxDuration: 0.1)
        let str = street
        randomDelay(maxDuration: 0.1)
        let num = number
        randomDelay(maxDuration: 0.1)

        return "\(str) \(num)"
    }
}

/*:
Całe dane są rozbite na 2 property `street` oraz `number`.

 Zmiana adresu odbywa się za pomocą metody `change(street:number:)`. W tym wypadku symuluje ona pewien proces gdzie obie części wykonują się po różnym czasie (funkcja `randomDelay`). Ta implementacja sprawia, że jeżeli ta metoda zostanie wywołana z różnych wątków to możemy się spodziewać kłopotów...

 Do pobierania pełnego adresu używamy property `full`, które po prostu łączy obie dane w _pełny_ adres. Tu również dodany jest losowe opóźnienie.

 */

let concurrentQueue = DispatchQueue(label: "lekko.techno.concurrent.1", attributes: .concurrent)
let addressData = [("Szkolna", "13"), ("Sokołowska", "9"), ("Gnojna", "32"), ("Wiejska", "42"), ("Mokotowska", "1")].shuffled()

xtimeBlock("🙅 Problem") {

    // just so to code will run inside `timeBlock`
    let waiter = DispatchGroup()

    let address = Address(street: "Szkolna", number: "13");
    print("Initial value:", address.full)
    
    address.change(street: "Mokotowska", number: "1")
    print("Updated value:", address.full)

    for (street, number) in addressData {
        concurrentQueue
            .async(group: waiter) {
                address.change(street: street, number: number)
                print("Zmieniono na: \(address.full)")
            }
    }
    
    waiter.wait()
    print("\nOstatecznie: \(address.full)")
}

/*:

 Pierwsze dwa wywołania działają prawidłowo. W tym wypadku nie ma wyścigu ponieważ wszystko się dzieje na tym samym wątku.

 Problem zaczyna się w momencie gdy na równoległej kolejce uruchamiamy asynchronicznie zmianę wszystkich adresów. Wynikiem jest (jeżeli nie to trzeba uruchomić przykład jeszcze raz) ustawienie adresu który nigdy nie występował w danych wejściowych! Aplikacja nie crash-uje tylko działa dalej. Jeżeli coś takiego twa długo to może się okazać, że mamy gówniane dane i nasza konkurencja może zacierać ręce.

 # Bariera

 **Bariera** działa tak że pozwala dokończyć działanie wszystkim zdaniom, które już wystartowały. Jednocześnie blokuje wystartowanie zadań, które zostały dodane po barierze. De facto zmieniając kolejkę ze współbieżnej na seryjną (na czas wykonania tego zadania).

 ## Multiple readers single writer

 Wprowadzając odrobinę kreatywnej księgowości możemy zaimplementować takiego zwierza który pozwala czytać z wielu wątków a gdy nadchodzi czas zapisu to wszystkie inne wątki są blokowane. [Multiple Readers Single Writer](https://www.objc.io/issues/2-concurrency/low-level-concurrency-apis/#multiple-readers-single-writer)

 */



class SafeAddress: Address {
    let isolation = DispatchQueue(label: "lekko.techno.isolation.1", attributes: .concurrent)

    override open func change(street: String, number: String) {
        isolation
            .async(flags: .barrier) {
                super.change(street: street, number: number)
            }
    }

    override open var full: String {
        var result = ""

        // We must use `sync` here so the return value will be here.
        // It still will be concurrent as the queue is concurrent.
        isolation.sync {
            result = super.full
            print("Wywołane z wątku: \(Thread.current)")
        }

        return result
    }
}

/*:

 Klasa `SafeAddress` posiada wewnętrzną kolejkę służącą do synchronizacji dostępu do współdzielonego zasobu.

 Nadpisana metoda `change(street:number:)` dodaje closure w którym użyta jest implementacja z super klasy. Natomiast zadanie jest dodane do kolejki z flagą `barrier`. To sprawia, że jeżeli były tam wcześniej wykonujące się zadania to kolejka je dokończy. Następnie wykona to zadanie a jeżeli doszły jakieś kolejne to zostaną wykonane po wykonaniu tego zadania.

 Property do czytania też synchronizuje swój dostęp do zasobu używając kolejki. Zwróć uwagę, że closure przekazany jest synchronicznie ale kolejka jest równoległa. Oznacza to, że na kolejce może być uruchomionych kilka takich zadań na raz.

 Zobaczmy to w praktyce. Przykład jest praktycznie identyczny.

 */

xtimeBlock("🥳 Rozwiązanie") {

    let waiter = DispatchGroup()

    let address = SafeAddress(street: "Szkolna", number: "13")
    print("Initial value:", address.full, "\n")

    for (street, number) in addressData {

        concurrentQueue.async(group: waiter) {
            address.change(street: street, number: number)
            print("Zmieniono na: \(address.full) - - - > Wywołane z wątku: \(Thread.current)")
            print("")
        }
    }
    
    waiter.wait()
    print("\nOstatecznie: \(address.full)")
}

/*:

Tym razem cały czas ustawiamy i odczytujemy poprawne dane!

 Można by było od razu tak zaimplementować tak klasę `Address` natomiast z synchronizacją jest związany koszt. Mogą być takie sytuacje gdzie wydajność jest kluczowa.

# Deadlock

_Zakleszczenie_ najczęściej występuje w sytuacji gdy dwa programy lub wątki współdzielą zasób i skutecznie uniemożliwiają sobie dostanie się do tego zasobu.

 W świecie iOS może się to objawiać przez zlecenie pracy synchronicznie na tą samą kolejkę

 */

xtimeBlock("🔒 Deadlock") {

    let serialQueue = DispatchQueue(label: "lekko.techno.serial.deadlock")

    print("Adding work to queue...")
    serialQueue.sync {

        print("Starting work on a task... and dispatching to the serial queue synchronously")

        serialQueue.sync {
            print("We should start work but...")
        }
    }

    print("😎 all is done")
}

/*:

 Aplikacja crashuje. Dzieje się tak dlatego, że dajemy zadanie do wykoania i czekamy na nie. Wewnątrz tego zadania ponownie dodajemy zadanie i na nie czekamy. Jednak to drugie zadanie nie może wystartować ponieważ to pierwsze nie skończyło. Mamy tu impas.

 Sytuacja nie zmienia się nawet gdy pierwsze wywołanie jest asynchroniczne:
 */

xtimeBlock("🤿 Deadlock with async") {

    let serialQueue = DispatchQueue(label: "lekko.techno.serial.deadlock")

    print("Adding work to queue...")
    serialQueue.async { // <-- this is now async

        print("Starting work on a task... and dispatching to the sirial queue synchronously")

        serialQueue.sync {
            print("😥😭 We should start work but...") // this never prints
        }
    }

    // TODO for the reader:
    // What will happen if you add more task on a serial queue?
    // hint: add a sleep so the code above will have a chance to run

    print("😎 all is done")
}

/*:

 Na pierwszy rzut oka jest lepiej ale problem jest dokładnie ten sam i dlatego nie widać wewnętrznego print-a.

 Rozwiązaniem jest unikanie takich sytuacji. Nie zawsze to jest takie proste jak na tym przykładzie a i tak jestem pewien, że trzeba na niego zerkać kilka razy. Cóż, kod wykonujący się jednocześnie jest trudny.

 */

//: [Wstecz](@previous) | [Następna strona](@next)

print("🏁")


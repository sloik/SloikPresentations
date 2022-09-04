//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # GCD Dispatch Queues
 */

import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


/*:

 # [Grand Central Dispatch - GCD](https://developer.apple.com/documentation/DISPATCH)

 Tworzenie, zarządanie i synchronizacja wątków nie jest taka prosta. Ciężko jest dobrać odpowiednią ilość wątków do dostępnych rdzeni/procesorów. Trzeba pomyśleć też o aktualbym obciążeniu systemu. Aby nieco odciązyć developera od tego rodzaju zadań Apple napisało GCD. Jest to zestaw ficzerów/umiejętności języka, bibliotek działających w czasie życia aplikacji oraz na poziomie systemu, które wspierają wykonywanie kodu na wielu procesorach/rdzeniach.

 Warto wiedzieć, że wszystko o czym rozmawialiśmy w `NSOperation` jest obiektową nakładką na API dostarczone przez GCD.

 # Dispatch Queue

 **Dispatch Queue** jak nazwa wskazuje jest kolejką. Dodajemy do niej bloki operacji które są wykonywane serialnie (jeden za drugim) w kolejności First In First Out. **Kolejka odpowiada za zarządzanie i wykonywanie zadań, które są na nią dodane**.

 Gdy dodajemy zadanie do wykonania na kolejce to system zarządza pulą wątków. Te wątki są tworzone wcześniej i reużywane między różnymi kolejkami. Ogranicza to problem tworzenia i niszczenia wątków, który z punktu widzenia czasu procesora jest kosztowny. Jeżeli wątków jest za mało to system stworzy kolejny. Co jest ważne to nie mamy kontroli nad tym na którym wątku będą wykonywane zadania z kolejki.

## Serial queue

 **Serial queue** wywołuje tylko jeden blok na raz. Czyli nie wystartuje następnego taks-a aż poprzedni nie zostanie ukończony.

 Natomiast można mieć kilka takich kolejek i wtedy z perspektywy tych bloków kilka na raz będzie jednocześnie wykonywanych.

## Concurent queue

 **Concurrent queue** woła blok również w kolejności FIFO ale nie czeka na jego zakończenie zanim wywoła kolejny w kolejce. Oznacza to, że nie można polegać na kolejności w jakiej zakończą się zadania.

 ## Main Queue

 Jest to **seryjna** kolejka przeznaczona na rzeczy związane z aktualizacją UI wykonująca jedno zadanie na raz. Wszystkie zadania są uruchamiane na głównym wątku aplikacji. Jest to wątek tworzony przy uruchomieniu aplikacji, któremu system przydziela najwyższy priorytet tak aby aplikacja była rezponsywna.

Ważne jest aby nie utożsamiać `main queue` z `main thread`. Może się zdarzyć, że inne kolejki też będą odpalać zadania na głównym wątku. Zdanie więcej można przeczytać na [Main thread and main queue: what’s the difference?](https://www.hackingwithswift.com/quick-start/concurrency/main-thread-and-main-queue-whats-the-difference)

 # Tworzenie Kolejki Seryjnej

 Zaletą takiej kolejki jest to, że synchronizuje nam dostęp do współdzielonego zasobu. Gwarantując, że w danym czasie tylko jeden wątek z niego korzysta.

 */

let serialQueue1 = DispatchQueue(label: "lekko.techno.serial.queue.1")

/*:

 ### QoS - Quality of Service

Możemy dać dla systemu wskazówkę jak ważna jest dla nas ta kolejka czyli jak często sytem powinien wykonywać zadania na nią przesłane. Po konkretne wartości zapraszam rzucić okiem do dokumentacji lub kodu.

 */

let serialQueue2 = DispatchQueue(label: "lekko.techno.serial.queue.2", qos: .default)


/*:

 # Tworzenie Kolejki "Równoległej"

 */

let concurrentQueue = DispatchQueue(label: "lekko.techno.concurrent.queue.1", attributes: .concurrent)

/*:

 # Global Queues

 System dostarcza nam juz globale kolejki równoległe z których możemy korzystać.

 * [Stara ale jara dokumentacja](https://developer.apple.com/library/content/documentation/General/Conceptual/ConcurrencyProgrammingGuide/OperationQueues/OperationQueues.html#//apple_ref/doc/uid/TP40008091-CH102-SW5)
 * [Nowsza dokumentacja](https://developer.apple.com/documentation/dispatch/dispatchqueue/2300077-global)

 Jeżeli potrzebujemy równoległej kolejki to lepiej jest używać tych dostarczonych przez system. Pozwoli to ograniczyć ilość wątków uzywanych przez aplikacje. Jak pokazywaliśmy w poprzednich przykładach gdy ich jest za dużo to cały system przestaje być wydajny.

 */

let systemQueue = DispatchQueue.global(qos: .background)

/*:

 ## Dodawanie Zadań

 Zadania możemy dodawać bezpośrednio do kolejek przekazując im closure do wykonania.

 ### Synchroniczne i Asynchroniczne

 Kolejki seryjne (serial) oraz równoległe (concurent) mogą wykonywać zadania synchronicznie lub asynchronicznnie.

 Jeżeli zadanie jest wykonywane **synchronicznie** oznacza to, że wykonanie kodu jest _zablokowane_ na tej linijce. Dopiero gdy zadanie się wykona się to kod _pobiegnie_ dalej. Jest to takie samo zachowanie jak byśmy wywołali funkcję (z tą różnicą, że funkcja została by uruchomiona na aktualnym wątku). Do momentu zakończenia działania funkcji program w aktualnym miejscu nie poruszy się do przodu.

 Zadanie wysłane na kolejkę **asynchroniczne** nie czeka na zakończenie tego zadania. Bieg programu natychmiast przechodzi do nastepnej linijki kodu.

 */

xtimeBlock("🔪 Dodawanie Zadań 1") {
    
    print(#line ,"🍏 Before adding ALL tasks")

    print(#line, "🦊 Before on serial 1 with sync")
    // "As an optimization, this function invokes the block on the current thread when possible."
    serialQueue1.sync {
        sleep(1)
        print("🦊111111111111 -> Główny wątek: \(Thread.isMainThread)", #line)
    }
    print(#line, "🦊 After on serial 1 with sync")


    print(#line, "🐥 Before on private concurrent with sync")
    concurrentQueue.sync {
        sleep(1)
        print("🐥333333333333 -> Główny wątek: \(Thread.isMainThread)", #line)
    }
    print(#line, "🐥 After on private concurrent with sync")


    print(#line, "🍄 Before on global system with sync")
    systemQueue.sync {
        sleep(1)
        print("🍄555555555555 -> Główny wątek: \(Thread.isMainThread)", #line)
    }
    print(#line, "🍄 After on global system with sync")


    print(#line, "ℹ️ Adding async tasks...")


    print(#line, "🦋 Before on serial 2 with async")
    serialQueue2.async {
        sleep(1)
        print("🦋222222222222 -> Główny wątek: \(Thread.isMainThread)", #line)
    }
    print(#line, "🦋 After on serial 2 with async")


    print(#line, "🪲 Before on private concurrent with async")
    concurrentQueue.async {
        sleep(1)
        print("🪲444444444444 -> Główny wątek: \(Thread.isMainThread)", #line)
    }
    print(#line, "🪲 After on private concurrent with async")


    print(#line, "🐈 Before on global system with async")
    systemQueue.async {
        sleep(1)
        print("🐈666666666666 -> Główny wątek: \(Thread.isMainThread)", #line)
    }
    print(#line, "🐈 After on global system with async")


    print("🍎 After adding ALL tasks\n")
}

/*:

 Po wyniku w konsoli widać, że wykonanie kodu zatrzymało się gdy zadania były dodawane synchronicznie i nie czekało gdy zadania były dodawane asynchronicznie.

Poprzedni przykład pokazał wszystkie możliwe kombinacje jakie mogą wystąpić w doddawaniu zadań do kolejki (serial sync, serial async, concurent sync, concurent async). W przykładzie niżej skupimy się na _serial sync_:
 */


xtimeBlock("🏓 Dużo zadań seryjnych (sync)") {
 
    for i in 0...10 {
        print("🛫")
        
        // przed wywołaniem kolejnego bloku zaczeka na zakończenie poprzedniego
        serialQueue1.sync {
            sleep(1)
            let message = String(repeating: "\(i)", count: 5)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }
        print("🛬")
    }
}

/*:

 Może się zdażyć, że jako optymalizacje system wywoła zadanie z kolejki na głównym wątku. Istotne natomiast jest to, że za każdym razem kod _czeka_ na zakończenie zadania zanim przejdzie dalej.

 W przykładzie niżej dodamy wszystkie zadania asynchronicznie:

 */

xtimeBlock("🐇 Dużo zadań seryjnych (async)") {
    
    for i in 0...10 {
        print("🛫")
        serialQueue1.async {
            sleep(1)
            let message = String(repeating: "\(i)", count: 5)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }
        print("🛬")
    }

}

/*:

 Dodanie zadań i czas wykonania całej pętli był praktycznie _natychmiastowy_. Dopiero po pewnym czasie widać, że zadania wykonywały się w kolejności w jakiej zostały dodane do kolejki.

## Wiele seryjnych kolejek

 Wiemży że gdy zadanie dodajemy asynchronicznie to nie czekamy na zakończenie tego zadania. Dzięki temu w zależności od tego co chcemy zrobić można zlecać dodawanie zadań do różnych kolejek:

 */

xtimeBlock("👯‍♀️ Raz jedna seryjna raz druga seryjna (async)") {
    
    for i in 0...10 {
        if i.isMultiple(of: 2) {
            serialQueue1.async {
                sleep(1)
                let message = String(repeating: "\(i)", count: 20)
                print(message + "Serial 1 -> Główny wątek: \(Thread.isMainThread)")
            }
        } else {
            serialQueue2.async {
                sleep(1)
                let message = String(repeating: "\(i)", count: 20)
                print(message + "Serial 2 -> Główny wątek: \(Thread.isMainThread)")
            }
        }
    }
}

/*:

 Analizując wynik działania tego przykładu w konsoli widać, że całość wykonała się szybciej. Podzielenie pracy też było trywialne. Sprowadza się do uzycia 2 seryjnych kolejek wysyłania zadań na nie zgodnie z _jakąś logiką_.

### Dodawanie zadań do kolejki równoległej

Nie ma znaczenia czy kolejka jest serialna czy równoległa. Gdy dodajemy zadanie używając metody `sync` to będziemy _czekać_ a gdy `async` to program _pobiegnie_ dalej. Poniższe dwa przykłady to ilustrują.

To co jeszcze rzuca się w oczy to, że zadania na kolejce równoległej wykonały się, no cóż, równolegle.

 */

xtimeBlock("🌲🌲🌲 Dużo zadań równoległych (sync)") {
    
    for i in 0...10 {
        print("🛫", i)
        
        // przed wywołaniem kolejnego bloku zaczeka na zakończenie poprzedniego
        concurrentQueue.sync {
            sleep(1)
            let message = String(repeating: "\(i)", count: 20)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }

        print("🛬", i)
    }
}

xtimeBlock("🛣🛣🛣 Dużo zadań równoległych (async)") {
    
    for i in 0...10 {
        print("🛫", i)

        concurrentQueue.async {
            sleep(1)
            let message = String(repeating: "\(i)", count: 20)
            print(message + " -> Główny wątek: \(Thread.isMainThread)")
        }

        print("🛬", i)
    }
}

/*:

## DispatchWorkItem i  `Main Queue`

Zadanie które chcemy wykonać możemy opakować w obiekt klasy `DispatchWorkItem`. Chyba najczęstrzym powodem aby to robić w ten sposób jest opcja anulowania zadania. W przypadku API z closure-s zadanie jest wysłane i nie mamy jak tego zrobic. Mając referencje do `work item`a możemy zawołać na nim metodę [`cancel`](https://developer.apple.com/documentation/dispatch/dispatchworkitem/1780910-cancel)

 */


let taskToDo  = DispatchWorkItem {
    print("Jest Robota  -> Główny wątek: \(Thread.isMainThread)");
}

/*:

 Dość często zdarza się potrzeba _wrócenia_ na głowny wątek. Najczęściej wykonuje się _strzał_ sieciowy i rezultat odświeża UI. Te zmiany muszą być wykonane na głównym wątku.

 Aby _wrócić_ na główny wątek możemy zlecić wykonanie zadania na `main queue`.

 */


xtimeBlock("⛺️ Wołamy Główny Wątek") {
    
    Thread {
        print("Z innego wątku...  -> Główny wątek: \(Thread.isMainThread)");
        DispatchQueue.main.async(execute: taskToDo)
    }
    .start()
}

/*:

 # Za dużo wątków

 Im więcej jest tworzonych prywatnych kolejek tym więcej wątków jest tworzonych. Komupter ma ograniczone zasoby. Jak już wcześniej o tym było wspominane to może spowodować pogorszenie wydajności.

 Jednym ze sposobów na radzenie sobie z tym jest używanie globalnych kolejek. Natomiast są one równoległe. Kolejka seryjna ma tą zaletę, że wiemy że zadania będą się na niej wykonywać _jedno za drugim_.

 ## Oddelegowanie pracy kolejki

 Okazuje się, że można utworzyć kolejkę seryjną ale zlecić jej użycie kolejki globalnej. W ten sposób dostajemy działanie kolejki seryjnej a reużywamy wątki przeznaczone na kolejki globalne.

 */


timeBlock("🚄 Threads") {

    let targetQueue = DispatchQueue(label: "lekko.techno.threads.target", attributes: .concurrent)

    let sq1 = DispatchQueue(label: "lekko.techno.threads.1", target: targetQueue)
    let sq2 = DispatchQueue(label: "lekko.techno.threads.2", target: targetQueue)

    func jobToDo(queue: String, index: Int) {
        print("🛫 starting job", index, "on", queue)
        sleep(1)
        print("🛬 done job", index, "on", queue)
    }

    for index in 0...3 {
        sq1.async { jobToDo(queue: sq1.label, index: index) }
        sq2.async { jobToDo(queue: sq2.label, index: index) }
    }
}



//: [Wstecz](@previous) | [Następna strona](@next)

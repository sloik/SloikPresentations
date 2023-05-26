//: [Previous](@previous)

import Foundation
import PlaygroundSupport
PlaygroundPage.current.needsIndefiniteExecution = false


/*:

 # ✓ Task

 Task jest podstawowym pojęciem w Structured Concurrency. Jest tym dla asynchronicznych funkcji czym wątki dla synchronicznych funkcji.

Co trzeba o nim wiedzieć:

 * każda asynchroniczna funkcja jest uruchomiona _wewnątrz_ jakiegoś task-u.
 * task uruchamia tylko jedną funkcję na raz; pojedynczy task nie jest współbieżny
 * wszystkie wywołane funkcje async w tym task-u są uruchomione na tym samym task-u i wracają na ten sam task

 Task może być w jednym z trzech stanów:

 * suspended
 * running
 * completed

 ## Tworzenie Task-u

Aby utworzyć task wystarczy skorzystać z init-a który przyjmuje jako argument closure do wykonania.
 */

await run("🥷🏻") {
    print("🥷🏻 Task:", Task { print("🌜", #line)              })
    print("🥷🏻 Task:", Task { print("🌜", #line); return 42   })
    print("🥷🏻 Task:", Task { print("🌜", #line); return "42" })
    await Task.yield()
}


/*:

 Analizując wynik z konsoli widać, że task posiada dwa typy generyczne. Możemy jeszcze skoczyć do jego deklaracji i zobaczymy, że pierwszy z nich oznacza typ jaki jest zwracany z task-u. Z przykładów mamy odpowiednio typy Void, Int oraz String. Drugi z nich mówi jakiego typu błąd może być rzucony w trakcie działania task-a.

## Task-i Potomne

 Asynchroniczna funkcja może utworzyć nowy task natomiast domyślnie jest tworzony gdy funkcja jest uruchamiana. Utworzony task dziedziczy niektóre informacje od swojego rodzica (np. priorytet). Task dziecko może być uruchomiony równolegle z rodzicem ale rodzić zakończy się dopiero gdy wszystkie jego dzieci zakończą pracę.

 Innymi słowy. Asynchroniczna funkcja, która utworzyła task-i potomne nie _wyjdzie_ (zakończy swego działania) do momentu aż wszystkie task-i potomne (oraz ich dzieci) nie zakończą swojego działania.

 # Asynchroniczna funkcja - `async` / `await`

Aby oznaczyć, że funkcja *może* być asynchroniczna do jej definicji przed zwracanym typem dodajemy słowo kluczowe `async`.

 */

func asynchronousFunction() async {}

/*:
Co ciekawe funkcja nie musi wykonywać asynchronicznego kodu aby można było ją oznaczyć jako asynchroniczną. Jest to identyczne zachowanie jak ze słowem kluczowym `throws`.
 */

func throwingFunction() throws {}

/*:
Rzucająca funkcja _może_ rzucić wyjątkiem ale wcale nie musi tego robić. Ponownie funkcja asynchroniczna może oddać wątek na którym jest uruchomiona.

 Tu analogie się nie kończą. Przy wywołaniu funkcji rzucających musimy _udekorować_ ich wywołanie słowem kluczowym `try`.
 */

try? throwingFunction()

/*:
W wypadku funkcji asynchronicznych każde miejsce gdzie funkcja *może* oddać wątek na którym jest uruchomiona oznaczone jest słowem kluczowym `await`.
 */

await asynchronousFunction()

/*:
Kiedyś w tej serii mam nadzieje dotrzeć do momentu aby szczegółowo opowiedzieć jak działają kontynuacje. Bo to co się dzieje w tym momencie może być bardziej zaskakujące niż się wydaje.

 Nie wdając się w szczegóły _jak_ to chwili wywołania asynchronicznej funkcji jest tworzony nowy task dla tej funkcji. Oba task-i mogą być uruchomione równolegle ale rodzic musi zaczekać aż wszystkie task-i potomne się zakończą.

Co jest dla nas ważne w tym momencie to to, że kompilator nam patrzy na ręce i jest w stanie _rozumować_ o współbieżnym kodzie.

 ## `async throws`

 Jak już jesteśmy przy podobieństwach to jest jeszcze jedna kombinacja z jaką można się spotkać. Asynchroniczna funkcja która może rzucić wyjątkiem.
 */

func asyncThrowingFunction() async throws {}

/*:
Kolejność słów kluczowych jest ważna. Jestem pewien, że po kilku dniach poprawiania błędów kompilacji sama też wejdzie w krew.

Aby wywołać tą funkcje oczywiście będzie potrzebny asynchroniczny kontekst. Tym razem użyje do tego asynchronicznej funkcji.
 */

func asyncThrowingFunctionDemo() async {
    try? await asyncThrowingFunction()
}

/*:
Oczywiście nigdzie tej funkcji nie wywołuje ale kod się kompiluje a to znaczy, że jest zgodny z zasadami structured concurrency!

 Zwróć uwagę, że słowa kluczowe przy wywołaniu są tak jakby _odwrócone_. Podczas gdy w definicji najpierw mówimy, że kod jest asynchroniczny a potem, że może rzucić błąd. Tak przy wywołaniu najpierw mówimy, że kod może rzucić błąd a potem jest asynchroniczny. Dla jednych jest to naturalne dla innych mniej. Natomiast po paru dniach wchodzi w krew 😅

 # Co jeszcze można zrobić z Task-iem


 */

await run("yield") {
    await Task.yield()
}

await run("🛌 sleep") {
    print(Date.timeIntervalSinceReferenceDate)
    try? await Task.sleep(for: .seconds(1))
    print(Date.timeIntervalSinceReferenceDate)
}

await run("cancel") {

    let t = Task {
        await Task.isCancelled
    }

    t.cancel()
}

print("🏁")


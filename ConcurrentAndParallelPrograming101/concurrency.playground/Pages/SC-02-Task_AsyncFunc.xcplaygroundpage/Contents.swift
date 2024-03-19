//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)

import Foundation
import PlaygroundSupport
import SwiftUI

PlaygroundPage.current.needsIndefiniteExecution = true

swift_task_enqueueGlobal_hook = { job, _ in
     MainActor.shared.enqueue(job)
}

/*:

 # ✓ Task i asynchroniczne funkcje

 Task jest podstawowym pojęciem w Structured Concurrency. Jest tym dla asynchronicznych funkcji czym wątki dla synchronicznych funkcji.

Co trzeba o nim wiedzieć:

 * każda asynchroniczna funkcja jest uruchomiona _wewnątrz_ jakiegoś task-u.
 * task uruchamia tylko jedną funkcję na raz; pojedynczy task nie jest współbieżny
 * wszystkie wywołane funkcje async w tym task-u są uruchomione na tym samym task-u i wracają na ten sam task (nie mylić z wątkiem!)

 Task może być w jednym z trzech stanów:

 * suspended
 * running
 * completed

 ## Relacja Task-a z wątkami

    Task jest abstrakcją która może być uruchomiona na dowolnym wątku. Wątek na którym jest uruchomiony task może się zmieniać w czasie jego życia. Task może być uruchomiony na jednym wątku, zawieszony, a następnie wznowiony na innym wątku. Dzięki temu system optymalnie może wykorzystywać zasoby i nie blokować żadnego wątku.

    Z takim modelem wiąże się pewna niedogodność. Otóż świat zastany po zawieszeniu może być zupełnie inny niż przed zawieszeniem. Dlatego jeżeli kod ma takie punkty to wszelkiego rodzaju sprawdzenia/guard-y/walidacje należy wykonać jeszcze raz.

 W przeciwieństwie do wątków Task-i są tanie. W gruncie rzeczy można tworzyć ich dużą ilość (dziesiątki tysięcy). System zajmie się tym aby odpowiednio nimi zarządzać oraz tym aby wszystkie wątki miały zajęcie i aby nie było ich za dużo. W praktyce okazuje się, że jest tyle uruchomionych task-ów ile urządzenie ma rdzeni (do każdego rdzenia jest przypisany wątek).

 ## Tworzenie Task-u

Aby utworzyć task wystarczy skorzystać z init-a który przyjmuje jako argument closure do wykonania (operation).

 */

await run("🥷🏻") {

    let t1 = Task {      }
    let t2 = Task { 42   }
    let t3 = Task { "42" }

    func ups() throws -> Int { 69 }
    let t4 = Task { try ups() }

    Task.detached(priority: .none, operation: {})

    print(t1, t2, t3, t4, separator: "\n")
}

/*:

 > Tak utworzone Task-i są *unstructured*. Dokładniej o tym opowiem później.

 Analizując wynik z konsoli widać, że task posiada dwa typy generyczne. Możemy jeszcze skoczyć do jego deklaracji i zobaczymy, że pierwszy z nich oznacza typ jaki jest zwracany z task-u gdy ten się _powiedzie_. Z przykładów mamy odpowiednio typy Void, Int oraz String. Drugi z nich mówi jakiego typu błąd może być rzucony w trakcie działania task-a.

Warto wiedzieć, że tak utworzony task dziedziczy priorytet, kontekst aktora z kodu który go utworzył (np. MainActor) oraz druga rzecz to _task local values_. Jeżeli tego nie chcemy to jest możliwość utworzenia _czystego_ task-a za pomocą statycznej funkcji `Task.detached` gdzie można sobie wybrać odpowiednią wersje.

🤓 Jeszcze jedna rzecz o której trzeba pamiętać. Closure w task-u tak utworzonym jak w przykładach silnie łapie referencje do `self`. Ma to fajny efekt, że w ciele closure nie trzeba pisać `self`. Na czas życia tego task-a jest tworzony retain cycle, który **po zakończeniu całej pracy** jest przerywany. Może być taka sytuacja, że ten blok trzyma instancję `self` do zakończenia pracy. Oczywiście określenie w capture list [weak self] przywraca znany świat z closure-s (ale jeżeli na samym początku i tak robisz taniec `guard let self else { return }` to nie ma sensu dawać self weak). `Task.detached` nie łapie domyślnie `self`.

 🤓 Ciekawym przypadkiem jest też task `t4`. Wywołuje w nim rzucającą funkcję `ups` a nie ma potrzeby owijania jej w blok `do catch`. Task po cichu ignoruje wszelkie błędy rzucone w tym closure. Ciężko powiedzieć czy to jest ficzer czy nie. Z jednej strony jeżeli ktoś nie chce *handlować* błędu to nie musi tego robić a z drugiej nie wiemy czy zostało to zrobione specjalnie czy po prostu zapomniane. Jak coś to możemy dopisać block `do catch`.

## Po co tworzyć task-i?

 Odpowiedz pierwsza jest wręcz prostacka. Ponieważ inaczej kod się nie skompiluje. Mniej prostacka jest taka, że nie jesteśmy w _asynchronicznym kontekście_ i musimy go jakoś utworzyć. Bardziej praktyczna to najzwyczajniej w świecie chcemy aby jakaś praca wykonała się równolegle/współbieżnie z inną.

## Task-i Potomne w Structured Concurrency

 Asynchroniczna funkcja może utworzyć nowy task. Utworzony task dziedziczy niektóre informacje od swojego rodzica (np. priorytet). Task dziecko może być uruchomiony równolegle z rodzicem ale rodzić zakończy się dopiero gdy wszystkie jego dzieci zakończą pracę.

 Innymi słowy. Asynchroniczna funkcja, która utworzyła task-i potomne (structured) nie _wyjdzie_ (zakończy swego działania) do momentu aż wszystkie task-i potomne (oraz ich dzieci) nie zakończą swojego działania.

 > W tym momencie zboczymy trochę z task-ów a skupimy się na dwóch nowych słowach kluczowych. Spokojnie zaraz wrócimy do Task-ów.

 # Asynchroniczna funkcja - `async` / `await`

Aby oznaczyć, że funkcja *może* wykonywać asynchroniczny kod, do jej definicji przed zwracanym typem dodajemy słowo kluczowe `async`. Z punktu widzenia kompilatora już w tym momencie jest asynchroniczna i będzie nas pilnować przy każdym jej wywołaniu.

 */

func asynchronousFunction() async {}

/*:

 Można o tym myśleć że typ tej funkcji to `() -> async Void`. Łatwo się też o tym przekonać. Poniższy kod się nie kompiluje (trzeba odkomentować linijkę):

 */

// 💥: Invalid conversion from 'async' function of type '() async -> ()' to synchronous function type '() -> Void'
// let referenceToVoidFunction: () -> Void = asynchronousFunction

 /*:

 Sama funkcja nie musi wykonywać asynchronicznego kodu aby można było ją oznaczyć jako asynchroniczną. Jest to identyczne zachowanie jak ze słowem kluczowym `throws`.

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

 Każda asynchroniczna funkcja jest uruchomiona _wewnątrz_ jakiegoś task-a.

 ## `async throws`

 Jak już jesteśmy przy podobieństwach to jest jeszcze jedna kombinacja z jaką można się spotkać. Asynchroniczna funkcja która może rzucić wyjątkiem.
 */

func asyncThrowingFunction() async throws {}

/*:
Kolejność słów kluczowych jest ważna. Jestem pewien, że po kilku dniach poprawiania błędów kompilacji sama też wejdzie w krew.

## Wywołanie funkcji async

Aby wywołać tą funkcje oczywiście będzie potrzebny asynchroniczny kontekst. Tym razem użyje do tego asynchronicznej funkcji. Można też taki kontekst stworzyć tworząc task (jak wyżej) lub skorzystać w SwiftUI z modyfikatora `task`.
 */

func asyncThrowingFunctionDemo() async {
    try? await asyncThrowingFunction()
}

/*:
Oczywiście nigdzie tej funkcji nie wywołuje ale kod się kompiluje a to znaczy, że jest zgodny z zasadami structured concurrency!

 Zwróć uwagę, że słowa kluczowe przy wywołaniu są tak jakby _odwrócone_. Podczas gdy w definicji najpierw mówimy, że kod jest asynchroniczny a potem, że może rzucić błąd. Tak przy wywołaniu najpierw mówimy, że kod może rzucić błąd a potem jest asynchroniczny. Dla jednych jest to naturalne dla innych mniej. Natomiast po paru dniach wchodzi w krew 😅

 Samo miejsce wywołania jest oznaczone słowem kluczowym `await`. W pewnym sensie `async` jest dla kompilatora a `await` dla programisty i kompilatora. Kompilator wie, że w tym miejscu **może** (nie musi!) utworzyć _punkt zawieszenia funkcji_ do którego wróci gdy asynchroniczna praca zostanie wykonana. Dla programisty aby podobnie jak z `try` widział czytelnie w kodzie miejsca gdzie program może zacząć asynchroniczną prace.

 Dzięki parze `async` i `await` kompilator wie czy jesteśmy w miejscu gdzie asynchroniczna praca może zostać wykonana. Tym samym **każdy await** jest miejscem gdzie task może przestać być wykonywany. Nazwijmy to *zdjęty* z wątku tak aby inne task-i mogły iść do przodu ze swoją pracą.

 Gdy funkcja asynchroniczna jest uruchamiana to domyślnie (gdy nie jest przypisana do żadnego aktora [o nich jeszcze powiemy]) jest uruchamiana na domyślnym `executor`-ze. Executor odpowiada za przyjmowanie `job`ów i ich uruchamianie. I tak np. jeden task może być uruchamiany i zawieszany wiele razy będąc częścią jednego job-a. Detalami jeszcze kiedyś się zajmiemy ale też zachęcam do poszukania więcej informacji we własnym zakresie.

 ## Wywoływanie większej ilości asynchronicznych funkcji

 Co się dzieje w momencie gdy asynchroniczna funkcja wywołuje inne asynchroniczne funkcje? Zobaczmy to na przykładzie:

 */

await run("🫏 async in async") {

    func someAsync1() async { print(#function) }
    func someAsync2() async { print(#function) }
    func someAsync3() async { print(#function) }

    func multipleAsyncCalls() async {
        await someAsync1()
        await someAsync2()
        await someAsync3()
    }

    await multipleAsyncCalls()
}

/*:

Zakładając, że funkcje `someAsync1|2|3` nie tworzą żadnych task-ów (korzystając z API do structured concurrency) to ich wykonanie wygląda dość standardowo.

 Z punktu widzenia `multipleAsyncCalls` nie ma żadnej asynchroniczności. Kolejna linijka jest wykonana w momencie gdy cała praca w poprzedniej jest wykonana.

 Ważne jest aby w tej sytuacji rozróżnić dwie rzeczy. Jedna to, że funkcja jest zawieszona i w pewnym sensie czeka. Natomiast task na którym jest uruchomiona zajmuje się wywołaniem następnych funkcji. No chyba, że akurat system uznał, że można go na zawiesić i dać szansę innym.


 # Co jeszcze można zrobić z Task-iem

Zanim przejdziemy dalej chciałbym opowiedzieć o jeszcze kilku występujących dostępnych metodach.

## `sleep`

 Prędzej czy póżniej pojawia się potrzeba aby task zaczekał chwile.

 */

await run("🥱 sleep") {
    print("before")
    try? await Task.sleep(for: .seconds(5))
    print("after")
}


 /*:

Task _biegnie_ do wywołania `sleep` po czym zatrzymuje wykonywanie task-u. Co jest bardzo ważne wątek nie jest blokowany i może w tym czasie uruchomić inne task-i. Ogólnie to mógłbym powiedzieć, że należy przestać myśleć o wątkach (co jest delikatnym uproszczeniem). Następnie po określonym czasie task _biegnie_ dalej.

W sytuacji gdy jakiś kod uśpi wątek to task też jest zatrzymany (nie wykonuje pracy). Przypominam, że pod spodem to na wątku się wykonuje cała praca. Task też nie "przeskakuje" na inny wątek gdy ten jest uśpiony.

## `value`

  Widzieliśmy wcześniej, że task posiada typ generyczny na sukces. Tym sukcesem jest wartość zwracana z tego task-u. Możemy ją otrzymać używając property `value`.

  */

await run("👑 value") {
    let t: Task<Int, Never> = Task {
        try? await Task.sleep(for: .seconds(1))
        return 42
    }

    let result = await t.value

    print(result)
}

/*:

 W miejscu użycia `value` task zaczeka (kompilator wymusi użycie await) na zakończenie task-a potomnego.

 To jest sposób aby wymusić _synchronizację_ takiego unstructured Task-a. Bez tego `await` na `value` funkcja (task dla tej funkcji) może zakończyć się wcześniej.
 */

await run("🐇 unstructured and unmanaged task") {
    Task {
        try? await Task.sleep(for: .seconds(1))
        print("🐢 started in unstructured task example")
    }
}

/*:

 Sam przykład startuje i wykonuje się błyskawicznie. Dopiero po jakimś czasie widać print z utworzonego task-a.

 ## `yield`

Bycie dobry obywatelem jest zawsze spoko. Za pomocą metody `yield` aktualnie uruchomiony task może dać znać systemowi, że może wstrzymać swoją prace. To daje szanse innym task-om na działanie.

 */

await run("🪨 yield") {

    for _ in 1...5 {
        // hard work
        try? await Task.sleep(for: .seconds(1))

        // give system a hint that it may switch to something else
        await Task.yield()
    }
}

/*:
Wywołanie statycznej metody `yield` daje znać systemowi, że może on zawiesić ten task i zająć się wykonaniem innego. Dzięki temu więcej task-ów może wykonywać pracę i cały sytem sprawia wrażenie bardziej respnsywnego.

## `cancel`

Anulowanie zleconej pracy pojawia się bardzo szybko w prawdziwym życiu. Do anulowania zadania służy metoda `cancel`.
 */


await run("🚫 cancel") {

    let t = Task {
        try? await Task.sleep(for: .seconds(5))
    }

    t.cancel()

    // make sure that taks finishes before the end of the closure
    await t.value
}

/*:

 Ręczne anulowanie task-ów nie rozwiązuje problemu co jak wewnątrz tego zadania utworzone zostanie kolejne. Tym problemem (nie tylko) zajmuje się właśnie structured concurrency, które wykorzystuje wiedzę o task-ach potomnych aby je również anulować.

 Uchylając rąbka tajemnicy powiem, że task-i posiadają coś takiego jak _task local values_. W pewnym sensie można o tym myśleć jak o _zmiennych statycznych_ lub trochę jak o _environment_ z SwiftUI. Są one dostępne z hierarchii task-ów ale o nich opowiem już gdy zapoznamy się lepiej z samym structured concurrency.

 ## `isCanceled` i `checkCancellation`

 Podobnie jak w starym świecie nie wystarczy powiedzieć, że tak jest anulowany. Trzeba jeszcze gdzieś to sprawdzić i przerwać pracę.

 Zaraz zaraz, przecież ostatni przykład nie trwał 5 sekund. Dlaczego?

 Napiszę ten sam przykład tylko tym razem troszeczkę inaczej:

 */

await run("🏏 cancel") {

    let t = Task {
        do {
            try await Task.sleep(for: .seconds(5))
        } catch {
            print("Error:", type(of: error), error)
        }
    }

    t.cancel()

    // make sure that taks finishes before the end of the closure
    await t.value
}

/*:

 Jak widać trikiem okazała się obsługa błędu. Metoda sleep jest w stanie _dowiedzieć się_, że znajduje się w hierarchii która jest anulowana i w tym momencie rzuca błąd. Można to łatwo sprawdzić zamieniając wywołanie metody `sleep` na inną która *nie współpracuje* z systemem anulowania.

 */

func block(for duration: TimeInterval) async {
    let start = Date()
    while Date().timeIntervalSince(start) < duration {
        // do nothing
    }
}

await run("🧱 cancel -- blocking") {

    let t = Task {
        await block(for: 5)
    }

    t.cancel()

    // make sure that taks finishes before the end of the closure
    await t.value
}

/*:
Funkcja `block(for:)` ma pętlę która nic nie robi. Natomiast warunkiem jest to, że ma wykonywać tą pętlę przez określony czas. Ewidentnie widać że czas wykonania tego task-a jest w okolicach 5s. To znaczy, że mimo iż nie chcę tej pracy wykonywać to i tak ona się dzieje.

 Jak możemy temu zaradzić?

 Nie ma jednej dobrej metody. Wszystko zależy od tego co robimy. Czasem można rzucić błędem, innym razem zwrócić `nil`/`.none`. Jeszcze innym zwrócić do tej pory wykonaną pracę w nadziei, że jednak do czegoś się jeszcze przyda.

 */

func cooperativeBlock(for duration: TimeInterval) async throws {
    let start = Date()
    while Date().timeIntervalSince(start) < duration {

        print(Date.now, Task.isCancelled)

        if Task.isCancelled {
            throw CancellationError()
        }
    }
}

await run("👫 cancel -- cooperative") {

    let t = Task {
        try? await cooperativeBlock(for: 5)
    }

    t.cancel()

    // make sure that taks finishes before the end of the closure
    await t.value
}

/*:
Funkcja `cooperativeBlock(for:)` tym razem jest dobrym obywatelem. W kluczowym momencie sprawdza czy praca dalej jest potrzebna. Jeżeli nie (taks został anulowany) to rzuca błędem. Sprawdzenie tego statusu odbywa się za pomocą statycznego property `isCancelled`.

 Jeszcze raz powtórzę. Nie trzeba w tym miejscu rzucać. Można zwrócić częściowy rezultat, .none lub dać zwykłego return-a. Wszystko zależy od tego _o co chodzi_ w zadaniu.

Jest jeszcze jedna opcja na anulowanie zadania. Tym razem za pomocą metody `checkCancellation`.

 */

func cooperativeBlock2(for duration: TimeInterval) async throws {
    let start = Date()
    while Date().timeIntervalSince(start) < duration {
        print(Date.now, Task.isCancelled)

        try Task.checkCancellation()
    }
}

await run("🌺 cancel -- cooperative2") {

    let t = Task {
        do {
            try await cooperativeBlock2(for: 5)
        } catch {
            print("Error:", type(of: error), error)
        }
    }

    t.cancel()

    // make sure that taks finishes before the end of the closure
    await t.value
}

/*:
Metoda `checkCancellation` zawsze rzuca instancję `CancellationError`. Jeżeli nie potrzebujemy przekazywać dodatkowych informacji o błędzie to mamy wszystko.

 Na początku powiedziałem, że w sumie można tworzyć tyle task-ów ile chcemy. Jednak ten przykład powinien dać nam do myślenia. Co jak moje wszystkie zadania będą trwać bardzo długo? Problemu nie będzie jeżeli będziemy w kluczowych momentach sprawdzać czy task jest anulowany i czy możemy dać szansę innym (za pomocą metody yield). W przeciwnym wypadku cała praca musi być skończona zanim system zleci wykonanie kolejnego task-u.

 # Podsumowanie...

 W osobnym filmiku, kiedyś, zamierzam omówić bardziej dokładnie tą cześć "structured" w "structured concurrency".

 Na ten moment będziemy to traktować jako _specjalny sposób_ dzięki któremu kompilator zna relację między poszczególnymi task-ami. Jest to ważne, że dzieje się to w czasie kompilacji a jak wiemy kompilator to jest nasz przyjaciel.

 To nie wszystko co można powiedzieć o Task-ach ale na ten moment wystarczająco aby można było przejść dalej.

 # Linki

 * [WWDC'23 - Beyond the basics of structured concurrency](https://developer.apple.com/wwdc23/10170)
 * [WWDC Notes: Swift concurrency: Behind the scenes](https://www.donnywals.com/wwdc-notes-swift-concurrency-behind-the-scenes/)
 * [Task Groups in Swift explained with code examples](https://www.avanderlee.com/concurrency/task-groups-in-swift)
 * [TaskGroup as a workflow design tool](https://trycombine.com/posts/swift-concurrency-task-group-workflow/)
 * [Detached Tasks in Swift explained with code examples](https://www.avanderlee.com/concurrency/detached-tasks)
 * [SwiftUI's .task modifier](https://alexanderweiss.dev/blog/2023-03-05-swiftui-task-modifier)




 */

print("🏁")

//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)

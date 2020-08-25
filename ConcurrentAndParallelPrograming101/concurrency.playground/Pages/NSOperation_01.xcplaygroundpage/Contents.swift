//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSOperation
 */

import Foundation

/*:
 **NSOperation** pozwala nam opakować jakiś kawałek pracy i wykonać go później (hint: command pattern). NSOperacja jest *maszyną stanu*:
 * *Ready* - po utworzeniu
 * *Executing* - po wywołaniu metody start
 * *Canceled* - po wywołaniu metody cancel
 * *Finished* - po zakończeniu pracy lub po wywołaniu metody cancel
 
 NSOperation ma wystawione property które możemy sprawdzać w jakim stanie obcencie się znajduje. Dodatkowo możemy też zarejestrować się na notyfikacje przy użyciu KVO.
 
 Jednym ze sposobów dostarczenia funkcjonalności dla operacji jest utworzenie własnej podklasy. Wystarczy w takim przypadku nadpisać metode *main*. Kolejnym sposobem jest skorzystanie z konkretnej subklasy już dostępnej w foundation jak *NSBlockOperation*, która przyjmuje zadania jako bloki do wykonania.
 
 Każde z zadań/operacji może mięc przypisany odpowiedni priorytet. Ukrywa się to pod enumem NSQualityOfService i w zależności od tego jakiego rodzaju mamy zadanie to powinniśmy przyposać odpowiedni poziom.
*/
//: ## Tworzenie Operacji

let taskDoWykonania = BlockOperation {
    sleep(3)
    print("Super ciezka robota -> Glowny watek: \(Thread.isMainThread)")
}

//: Przy operacji mozemy ustawic jej priorytet z jakim ma sie wykonać na kolejce (o kolejkach później). [Dokumntacja](https://developer.apple.com/reference/foundation/operation/1411204-queuepriority)
taskDoWykonania.queuePriority = .normal

//: Jak rownież dać hint do systemu ile zasobów ma przydzielić na wykonaie tego zadania. [Dokumentacja](https://developer.apple.com/reference/foundation/operation/1413553-qualityofservice)
taskDoWykonania.qualityOfService = .utility


xtimeBlock("Tworzenie Operacji") {
    print("Przed wystartowaniem")
    taskDoWykonania.start()
    print("Po wystartowaniu")
}

//: Jak widzimy tego typu zadnie jest wykonane synchronicznie. To znaczy, że   wykonanie kodu "zatrzymało się" na linijce gdzie operacja została wystartowana na czas jej wykonania. 

// Można dodać wiecej jak jedną operacje do wykonania.

let multiOperacja = BlockOperation()

multiOperacja.addExecutionBlock {
    sleep(3)
    print("Op1 -> Glowny watek: \(Thread.isMainThread)")
}

multiOperacja.addExecutionBlock {
    sleep(1)
    print("Op2 -> Glowny watek: \(Thread.isMainThread)")
}

multiOperacja.addExecutionBlock {
    sleep(1)
    print("Op3 -> Glowny watek: \(Thread.isMainThread)")
}

xtimeBlock("Multiopereacja") {
    print("przed")
    multiOperacja.start()
    print("po")
}


//: Kolejne dodawane bloki do operacji mogą się wykonywać współbieżnie. Oczywiście nie mamy gwarancji ile bloków zostanie wykonanych równolegle ani w jakiej kolejności.

//: [Wstecz](@previous) | [Następna strona](@next)


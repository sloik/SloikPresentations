//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSOperation
 */

import Foundation

/*:
 **NSOperation** pozwala nam opakować jakiś kawałek pracy i wykonać go później (hint: command pattern). NSOperacja jest *maszyną stanu*:
 * *Ready* - po utworzeniu
 * *Executing* - po wywołaniu metody start
 * *Cancelled* - po wywołaniu metody cancel
 * *Finished* - po zakończeniu pracy lub po wywołaniu metody cancel
 
 NSOperation ma wystawione property które możemy sprawdzać w jakim stanie obecnie się znajduje. Dodatkowo możemy też zarejestrować się na notyfikacje przy użyciu KVO.
 
 Jednym ze sposobów dostarczenia funkcjonalności dla operacji jest utworzenie własnej podklasy. Wystarczy w takim przypadku nadpisać metodę *main*. Kolejnym sposobem jest skorzystanie z konkretnej subklasy już dostępnej w Foundation jak *NSBlockOperation*, która przyjmuje zadania jako bloki do wykonania.
 
 Każde z zadań/operacji może mieć przypisany odpowiedni priorytet. Ukrywa się to pod enumem NSQualityOfService i w zależności od tego jakiego rodzaju mamy zadanie to powinniśmy przypisać odpowiedni poziom.
*/
//: ## Tworzenie Operacji

let taskToDo = BlockOperation {
    sleep(3)
    print("Super cięzka robota -> Główny wątek: \(Thread.isMainThread)")
}

//: Przy operacji mozemy ustawic jej priorytet z jakim ma się wykonać na kolejce (o kolejkach później). [Dokumentacja](https://developer.apple.com/reference/foundation/operation/1411204-queuepriority)
taskToDo.queuePriority = .normal

//: Jak rownież dać hint do systemu ile zasobów ma przydzielić na wykonanie tego zadania. [Dokumentacja](https://developer.apple.com/reference/foundation/operation/1413553-qualityofservice)
taskToDo.qualityOfService = .utility


xtimeBlock("Tworzenie Operacji") {
    print("Przed wystartowaniem")
    taskToDo.start()
    print("Po wystartowaniu")
}

//: Jak widzimy tego typu zadanie jest wykonane synchronicznie. To znaczy, że wykonanie kodu "zatrzymało się" na linijce gdzie operacja została wystartowana na czas jej wykonania.

// Można dodać więcej jak jedną operację do wykonania.

let multiOperation = BlockOperation()

multiOperation.addExecutionBlock {
    sleep(3)
    print("Op1 -> Główny wątek: \(Thread.isMainThread)")
}

multiOperation.addExecutionBlock {
    sleep(1)
    print("Op2 -> Główny wątek: \(Thread.isMainThread)")
}

multiOperation.addExecutionBlock {
    sleep(1)
    print("Op3 -> Główny wątek: \(Thread.isMainThread)")
}

xtimeBlock("Multioperacja") {
    print("Przed")
    multiOperation.start()
    print("Po")
}


//: Kolejne dodawane bloki do operacji mogą się wykonywać współbieżnie. Oczywiście nie mamy gwarancji ile bloków zostanie wykonanych równolegle ani w jakiej kolejności.

//: [Wstecz](@previous) | [Następna strona](@next)


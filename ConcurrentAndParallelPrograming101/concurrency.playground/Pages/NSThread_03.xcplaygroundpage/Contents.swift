//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

final class Test: NSObject {
    @objc func jobToDo() {
        print("Główny wątek: \(Thread.isMainThread)")
    }
}

let testInstance = Test()

//: Wątki są też tworzone w różnych innych okolicznościach jak np:
testInstance
    .performSelector(
        inBackground: #selector(testInstance.jobToDo),
        with: .none
    )

//: [Wstecz](@previous) | [Następna strona](@next)


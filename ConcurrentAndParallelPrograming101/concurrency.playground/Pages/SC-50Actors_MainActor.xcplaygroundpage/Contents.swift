//: [Previous](@previous)

import Foundation

//swift_task_enqueueGlobal_hook = { job, _ in
//     MainActor.shared.enqueue(job)
//}


/*:

 # 🎭 Actor

 */

/*:

 ## Jaką rolę pełni aktor?

Strażnik własnych property. Typ referencyjny.

 # Main Actor

 >  Prawdopodobnie te przykłady trzeba będzie pobiec w projekcie na urządzeniu.

 Specjalny aktor, który służy do handlowania UI (wszystkie widoki z SwiftUI oraz ViewController-y). Jest powiązany z główną kolejką, która używa głównego wątku.

 ## Uruchamianie kodu na MainActor

 Aby wywołać kod na głównym wątku za pomocą MainActor-a należy skorzystać z metody `run` i przekazać jej closure do wykonania.
 */

await run("🪷 MainActor run") {
    await MainActor.run {
        print("Running on main actor")
    }
}

/*:

 ## `@Sendable`

 */

func asyncFunction() async { print(#function) }

await run("🪷 MainActor run") {
    await MainActor.run {
        print("Running on main actor")
        await asyncFunction()
        print("Done running on main actor")
    }
}

/*:

 ## `@MainActor`

 */

func longRunningAsyncWork(tag: Int) async {
    try? await Task.sleep(for: .seconds(2))

    print(#function, "done.")
}

func longRunningSyncWork() {

    let future = Date.now.addingTimeInterval(2)

    while Date.now < future {}

    print(#function, "done.")
}

@MainActor
func mainActorFunction() { print(#function) }

/*:
### Na klasie

 Dostęp do property i wywołanie metod będzie się odbywać przez `MainActor`a.
 */
@MainActor
class MainActorClass {

}

let mainActorClosure: () -> Void = { @MainActor in

}


/*:

# Links

 * [YT - How do Actors work in Swift?](https://www.youtube.com/watch?v=8jvtHCXJ4Ow)
 * [How main actor works](https://oleb.net/2022/how-mainactor-works/)
 * [Scala Asynchronous Programming](https://app.pluralsight.com/library/courses/scala-asynchronous-programming/table-of-contents)
 * [The Actor Reentrancy Problem in Swift](https://swiftsenpai.com/swift/actor-reentrancy-problem/)
 * [Swift Forums -
 Actor Reentrancy](https://forums.swift.org/t/actor-reentrancy/59484)
 * [Actors can rule your DDD world - Hannes Lowette - NDC Porto 2022](https://youtu.be/WDd1QSZBjHI)
 * [MainActor usage in Swift explained to dispatch to the main thread](https://www.avanderlee.com/swift/mainactor-dispatch-main-thread)

 */

//: [Next](@next)

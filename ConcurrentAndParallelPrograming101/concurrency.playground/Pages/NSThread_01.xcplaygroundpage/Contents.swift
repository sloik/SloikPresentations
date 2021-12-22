//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

//: Najprostrzym sposobem utworzenia wątku w iOS jest skorzystanie z klasy do której możemy przekazać blok z *zadaniem* .

let thread1 = Thread.init {
    print("1111111111111111111111111111111111111111")
}

let thread2 = Thread {
    print("2222222222222222222222222222222222222222")
}


//: Pamiętajmy, że należy wystartować takie wątki.
thread1.start()
thread2.start()

print("               Glowny watek: \(Thread.isMainThread)")
print("Aplikacja jest wielowatkowa: \(Thread.isMultiThreaded())")


//: [Wstecz](@previous) | [Następna strona](@next)

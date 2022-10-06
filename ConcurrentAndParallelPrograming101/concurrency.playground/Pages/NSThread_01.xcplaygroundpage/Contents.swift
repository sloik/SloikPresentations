//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

//: Najprostszym sposobem utworzenia wątku w iOS jest skorzystanie z klasy do której możemy przekazać blok z *zadaniem* .

let thread1 = Thread.init {
    print("🧶                Główny wątek: \(Thread.isMainThread)")
    print("🧶 Aplikacja jest wielowątkowa: \(Thread.isMultiThreaded())")
    print("🧶 1111111111111111111111111111111111111111")
}

let thread2 = Thread {
    print("🐬                Główny wątek: \(Thread.isMainThread)")
    print("🐬 Aplikacja jest wielowątkowa: \(Thread.isMultiThreaded())")
    print("🐬 2222222222222222222222222222222222222222")
}


//: Pamiętajmy, że należy wystartować takie wątki.
thread1.start()
thread2.start()

print("🌸                Główny wątek: \(Thread.isMainThread)")
print("🌸 Aplikacja jest wielowątkowa: \(Thread.isMultiThreaded())")


//: [Wstecz](@previous) | [Następna strona](@next)

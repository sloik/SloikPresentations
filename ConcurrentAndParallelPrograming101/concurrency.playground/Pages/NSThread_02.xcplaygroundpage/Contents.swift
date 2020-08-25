//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

var watki : [Thread] = []

for i in 0...20 {
    let t = Thread {
        let message = String(repeating: "\(i)", count: 20)
        print(message)
    }
    
    watki.append(t)
}

for t in watki {
    t.start()
}

print("               Glowny watek: \(Thread.isMainThread)")
print("Aplikacja jest wielowatkowa: \(Thread.isMultiThreaded())")


//: [Wstecz](@previous) | [Następna strona](@next)

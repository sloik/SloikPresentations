//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

var threads : [Thread] = []

for i in 0...20 {
    let createdThread = Thread {
        let message = String(repeating: "\(i)", count: 20)
        print(message)
    }
    
    threads.append( createdThread )
}

for thread in threads {
    thread.start()
}

print("               Glowny watek: \(Thread.isMainThread)")
print("Aplikacja jest wielowatkowa: \(Thread.isMultiThreaded())")


//: [Wstecz](@previous) | [Następna strona](@next)

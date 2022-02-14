//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

var threads : [Thread] = []

for i in 0...9 {
    let createdThread = Thread {
        let message = String(repeating: "\(i)", count: 20)
        print(message)
    }
    
    threads.append( createdThread )
}

for thread in threads {
    thread.start()
}

print("               Główny wątek: \(Thread.isMainThread)")
print("Aplikacja jest wielowątkowa: \(Thread.isMultiThreaded())")


//: [Wstecz](@previous) | [Następna strona](@next)

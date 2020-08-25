//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # NSThread
 */

import Foundation

class Test: NSObject {
    @objc func jestRobota() {
        print("Glowny watek: \(Thread.isMainThread)")
    }
}

let testowy = Test()

//: Wątki są też tworzone w różnych innych okolicznościach jak np:
testowy.performSelector(inBackground: #selector(testowy.jestRobota), with: nil)

//: [Wstecz](@previous) | [Następna strona](@next)


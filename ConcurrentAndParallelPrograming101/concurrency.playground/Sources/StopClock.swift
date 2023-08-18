import Foundation


public func timeBlock(_ label: String, block: ()->()) {
    let start = Date()
    
    print(label, "\n")

    block()

    let elapsedTime = Date().timeIntervalSince(start)
    print("\n" + label + " \(elapsedTime)\n\n")
}

public func xtimeBlock(_ label: String, block: ()->()) {}

public func run(_ label: String, block: @escaping () async -> Void) async {

    let start = Date()
    
    print(label, "\n")

    await block()

    let elapsedTime = Date().timeIntervalSince(start)
    print("\n" + label + " \(elapsedTime)\n")
}

public func xrun(_ label: String, block: () async -> Void) async {}

public var ___: Void {
    Thread.sleep(until: Date.now + 0.2)
    print("\n- - - - - - - - - - - - - -\n")
}

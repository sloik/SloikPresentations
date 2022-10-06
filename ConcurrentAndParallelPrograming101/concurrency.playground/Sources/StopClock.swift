import Foundation


public func timeBlock(_ label: String, block: ()->()) {
    let start = Date()
    
    print("Uruchamiam: " + label + "\n")
    
    block()

    let elapsedTime = Date().timeIntervalSince(start)
    print("\n" + label + " \(elapsedTime)\n\n")
}

public func xtimeBlock(_ label: String, block: ()->()) {}

import Foundation

public func randomDelay(maxDuration: Double) {
    let randomWait = arc4random_uniform(UInt32(maxDuration * Double(USEC_PER_SEC)))
    usleep(randomWait)
}

open class Address {
    private var street: String
    private var number: String
    
    public init(street: String, number: String) {
        self.street = street
        self.number = number
    }
    
    open func change(street: String, number: String) {
        randomDelay(maxDuration: 0.1)
        self.street = street
        randomDelay(maxDuration: 1)
        self.number = number
    }
    
    open var full: String {
        return "\(street) \(number)"
    }
}

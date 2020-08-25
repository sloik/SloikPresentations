import Foundation

public func randomDelay(maxDuration: Double) {
    let randomWait = arc4random_uniform(UInt32(maxDuration * Double(USEC_PER_SEC)))
    usleep(randomWait)
}

open class Adres {
    private var ulica: String
    private var numer: String
    
    public init(ulica: String, numer: String) {
        self.ulica = ulica
        self.numer = numer
    }
    
    open func zmien(ulica: String, numer: String) {
        randomDelay(maxDuration: 0.1)
        self.ulica = ulica
        randomDelay(maxDuration: 1)
        self.numer = numer
    }
    
    open var pelen: String {
        return "\(ulica) \(numer)"
    }
}

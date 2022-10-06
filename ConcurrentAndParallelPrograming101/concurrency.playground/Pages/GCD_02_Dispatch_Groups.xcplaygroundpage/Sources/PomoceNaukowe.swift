import Foundation

public enum Asynchronous {

    /// Does some work and calls `callback` closure asynchronously.
    public static func checkWhatWillHappen(callback: @escaping ()->()) {
        
        let systemQueue = DispatchQueue.global(qos: .background)

        systemQueue.async {
            sleep(5)
            print(".....")
            callback()
        }
    }
}

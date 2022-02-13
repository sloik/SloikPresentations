import Foundation

public class Asynchronous {
    
    public init() {}
    
    public func checkWhatWillHappen(callback: @escaping ()->()) {
        
        let systemQueue = DispatchQueue.global(qos: .background)
        
        print("Asynchroniczna: raz (stary wątek)")
      
        systemQueue.async {
            print("Super długie zadanie start...")
            sleep(5)
            print("Super długie zadanie stop...")
            sleep(5)
            callback()
        }
        
        print("Asynchroniczna: dwa (stary wątek)")
    }
}

import Foundation

public class Asynchroniczny {
    
    public init() {}
    
    public func zobaczCoSieStanie(callback: @escaping ()->()) {
        
        let systemowaKolejka = DispatchQueue.global(qos: .background)
        
        print("Asynchroniczna: raz (stary watek)")
      
        systemowaKolejka.async {
            print("Super dlugie zadanie start...")
            sleep(5)
            print("Super dlugie zadanie stop...")
            sleep(5)
            callback()
        }
        
        print("Asynchroniczna: dwa (stary watek)")
    }
}

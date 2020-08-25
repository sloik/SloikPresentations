//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Dziedziczenie / Własna Klasa Operacji
 */
import Foundation
import PlaygroundSupport


class ProstaOperacja: Operation {
    override func main() {
        sleep(1)
        print("Prosciej sie nie da -> Glowny watek: \(Thread.isMainThread)");
    }
}

xtimeBlock("Prosta Operacja") {
   ProstaOperacja().start()
   ProstaOperacja().start()
   ProstaOperacja().start()
}

//: Tak utworzona klasa nie jest asynchroniczna. Natomiast jak widzimy jest bardzo prosta w tworzeniu. W przypadku jeżeli chcemy utworzyć asynchroniczną operację to musimy dodatkowo nadpisać jeszcze metody i propertisy: *start()*, *isAsynchronous*, *isExecuting*, *isFinised*. Dodatkowo musimy **sami** tworzyć i zarządzać wątkami.


class BazowaAsynchronicznaOperacja: Operation {
//: Sami musimy zarządzać stanem.
    enum State {
        case Ready, Executing, Finished
        func keyPath() -> String {
            switch self {
            case .Ready:
                return "isReady"
            case .Executing:
                return "isExecuting"
            case .Finished:
                return "isFinished"
            }
        }
    }
//: Zgodność z KVO
    var state = State.Ready {
        willSet {
            willChangeValue(forKey: newValue.keyPath())
            willChangeValue(forKey: state.keyPath())
        }
        didSet {
            didChangeValue(forKey: oldValue.keyPath())
            didChangeValue(forKey: state.keyPath())
        }
    }
    
//: Wielkie nadpisywanie
    override var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override var isExecuting: Bool {
        return state == .Executing
    }
    
    override var isFinished: Bool {
        return state == .Finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
//: Sami musimy tworzyc i zarzadzac watkami.
 
    override func start() {
        if isCancelled {
            state = .Finished
            return
        }
        
        main()
        state = .Executing
    }
    
    override func cancel() {
        state = .Finished
    }
}

//: Ponieważ tamta logika będzie identyczna to możemy użyć jej jako klasy bazowej do naszych konkretnych asynchronicznych zadań. Co jest bardzo ważne **musimy pamiętać o zmianie stanu** gdy zadanie jest wykonane. Jest to wymagane aby nasza operacja była prawidłowo obsługiwana przez kolejki zadań (o czym później).
class AsynchroniczneZadanie: BazowaAsynchronicznaOperacja {
    override func main() {
        if isCancelled {
            state = .Finished
            return
        }
        
        let watek = Thread.init {
            sleep(2)
            print("Taka Asynchroniczna Magia -> Glowny watek: \(Thread.isMainThread)");
            self.state = .Finished            
        }
        
        watek.start()
    }
}

//: Chcmey aby plac zabaw nie "umieral" zanim nie zostanie wykonane zadanie w tle.
PlaygroundPage.current.needsIndefiniteExecution = true

xtimeBlock("AsynchroniczneZadanie") {
    print("Przed zadaniami...")
    
    AsynchroniczneZadanie().start()
    AsynchroniczneZadanie().start()
    AsynchroniczneZadanie().start()
    AsynchroniczneZadanie().start()

    print("Po zadaniach...")
    
    //usypiamy glowny watek na chwile tak aby dac szanse na wykonanie sie zadania jeszcze w klamerkach ;)
//    sleep(3)
}

//: Jak na proste zadnie to na prawdę trzeba było się troszeczkę napisać aby wszystko zadziałało jak trzeba. Najgorsze, że sami musimy tworzyć wątek i na nim wykonywać operacje. Całe szczęście nie musimy tworzyć asynchronicznych podklas NSOperacji aby zdania wykonywały się asynchronicznie. W dalszej części zostaną omówione **kolejki operacji** na których możną uruchamiać klika na raz synchronicznych operacji przez co apropo de facto uzyskujemy asynchroniczne i równoległe wykonywanie operacji. Wszystko bez zarządzania wątkami! 💘


//: [Wstecz](@previous) | [Następna strona](@next)

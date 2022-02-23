//:[Spis Treści](Spis_Tresci) | [Wstecz](@previous) | [Następna strona](@next)
/*:
 > # Dziedziczenie / Własna Klasa Operacji
 */
import Foundation
import PlaygroundSupport


final class SimpleOperation: Operation {
    override func main() {
        sleep(1)
        print("Prościej się nie da -> Główny wątek: \(Thread.isMainThread)");
    }
}

timeBlock("🧤 Prosta Operacja") {
    SimpleOperation().start()
    SimpleOperation().start()
    SimpleOperation().start()
}

//: Tak utworzona klasa nie jest asynchroniczna. Natomiast jak widzimy jest bardzo prosta w tworzeniu. W przypadku jeżeli chcemy utworzyć asynchroniczną operację to musimy dodatkowo nadpisać jeszcze metody i propertisy: *start()*, *isAsynchronous*, *isExecuting*, *isFinished*. Dodatkowo musimy **sami** tworzyć i zarządzać wątkami.


class BaseAsynchronousOperation: Operation {
//: Sami musimy zarządzać stanem.
    enum State {
        case ready, executing, finished
        func keyPath() -> String {
            switch self {
            case .ready:
                return "isReady"
            case .executing:
                return "isExecuting"
            case .finished:
                return "isFinished"
            }
        }
    }
//: Zgodność z KVO
    var state = State.ready {
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
        return super.isReady && state == .ready
    }
    
    override var isExecuting: Bool {
        return state == .executing
    }
    
    override var isFinished: Bool {
        return state == .finished
    }
    
    override var isAsynchronous: Bool {
        return true
    }
    
//: Sami musimy tworzyć i zarządzać wątkami.
 
    override func start() {
        if isCancelled {
            state = .finished
            return
        }
        
        main()
        state = .executing
    }
    
    override func cancel() {
        state = .finished
    }
}

//: Ponieważ tamta logika będzie identyczna to możemy użyć jej jako klasy bazowej do naszych konkretnych asynchronicznych zadań. Co jest bardzo ważne **musimy pamiętać o zmianie stanu** gdy zadanie jest wykonane. Jest to wymagane aby nasza operacja była prawidłowo obsługiwana przez kolejki zadań (o czym później).
class AsynchronousTask: BaseAsynchronousOperation {
    override func main() {
        if isCancelled {
            state = .finished
            return
        }
        
        let thread = Thread.init {
            sleep(2)
            print("Taka Asynchroniczna Magia -> Główny wątek: \(Thread.isMainThread)");
            self.state = .finished
        }
        
        thread.start()
    }
}

//: Chcemy aby plac zabaw nie "umierał" zanim nie zostanie wykonane zadanie w tle.
PlaygroundPage.current.needsIndefiniteExecution = true

timeBlock("🙉 AsynchroniczneZadanie") {
    print("Przed zadaniami...")
    
    AsynchronousTask().start()
    AsynchronousTask().start()
    AsynchronousTask().start()
    AsynchronousTask().start()

    print("Po zadaniach...")
    
    // Usypiamy główny wątek na chwilę tak aby dać szansę na wykonanie się zadania jeszcze w klamerkach ;)
//    sleep(3)
}

//: Jak na proste zadanie to naprawdę trzeba było się troszeczkę napisać aby wszystko zadziałało jak trzeba. Najgorsze, że sami musimy tworzyć wątek i na nim wykonywać operacje. Całe szczęście nie musimy tworzyć asynchronicznych podklas NSOperacji aby zadania wykonywały się asynchronicznie. W dalszej części zostaną omówione **kolejki operacji** na których możną uruchamiać klika na raz synchronicznych operacji przez co apropo de facto uzyskujemy asynchroniczne i równoległe wykonywanie operacji. Wszystko bez zarządzania wątkami! 💘


//: [Wstecz](@previous) | [Następna strona](@next)

import Foundation

// Odrobina wieprzowiony aby zadziałało w placu zabaw. Klasa niczym się nie różni od tej zadeklarowanej w przykładzie ma tylko przyjazniejsza nazwe ;)
open class AsyncOperation: Operation {
    //: Sami musimy zarządzać stanem.
    public enum State {
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
    open var state = State.Ready {
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
    override open var isReady: Bool {
        return super.isReady && state == .Ready
    }
    
    override open var isExecuting: Bool {
        return state == .Executing
    }
    
    override open var isFinished: Bool {
        return state == .Finished
    }
    
    override open var isAsynchronous: Bool {
        return true
    }
    
    //: Sami musimy tworzyc i zarzadzac watkami.
    
    override open func start() {
        if isCancelled {
            state = .Finished
            return
        }
        
        main()
        state = .Executing
    }
    
    override open func cancel() {
        state = .Finished
    }
}

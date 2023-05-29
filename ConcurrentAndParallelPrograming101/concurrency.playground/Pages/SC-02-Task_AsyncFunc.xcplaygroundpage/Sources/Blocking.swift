import Foundation

public func block(for duration: TimeInterval) async {
    let start = Date()
    while Date().timeIntervalSince(start) < duration {
        // do nothing
    }
}


//public func asyncBlock(for time: TimeInterval, completion: @escaping () -> Void) {
//    DispatchQueue.global().async {
//        block(for: time)
//        completion()
//    }
//}


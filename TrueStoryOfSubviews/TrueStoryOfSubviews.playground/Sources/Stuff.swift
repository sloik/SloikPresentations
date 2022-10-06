
import CoreGraphics

// MARK: - Asserts

// NB: `@_exported` will make foundation available in our playgrounds
@_exported import Foundation

@discardableResult
public func assertTrue(_ predicate: Bool) -> String {
    return predicate ? "✅" : "❌"
}

@discardableResult
public func assertFalse(_ predicate: Bool) -> String {
    return predicate == false ? "✅" : "❌"
}

@discardableResult
public func assertEqual<A: Equatable>(_ lhs: A, _ rhs: A) -> String {
    return lhs == rhs ? "✅" : "❌"
}

@discardableResult
public func assertEqual<A: Equatable>(_ lhs: [A], _ rhs: [A]) -> String {
    return lhs == rhs ? "✅" : "❌"
}


@discardableResult
public func assertEqual<A: Equatable, B: Equatable>(_ lhs: (A, B), _ rhs: (A, B)) -> String {
    return lhs == rhs ? "✅" : "❌"
}


// MARK: - Playground Stuff

// running examples
public var __: Void { print("--") }
public var ____: Void {
    debugPrint()
    debugPrint()
    debugPrint()
}



public func xrun(_ nazwa: String? = nil, p: ()->()) {}
public func run(_ nazwa: String? = nil, p: ()->()) {
    struct S {
        public static var runCount = 0
    }
    
    let multi = (S.runCount * 8) + S.runCount
    let incr = nazwa == nil ? 0 : 1
    if let _ = nazwa { print("\(String(repeating:"+", count: S.runCount + multi))\(S.runCount==0 ? "" : " ")\(nazwa!) > ") }
    S.runCount += incr
    p()
    S.runCount -= incr
    if let _ = nazwa { print("\(String(repeating:"-", count: S.runCount + multi))\(S.runCount==0 ? "" : " ")\(nazwa!) > ") }
    debugPrint()
}

public func xtb(_ label: String, block: ()->()) {}
public func tb(_ label: String, block: ()->()) {
    print("Uruchamiam: " + label + "\n")
    
    let start = Date()
    block()
    let elapsedTime = Date().timeIntervalSince(start)
    
    print("\n" + label + " \(elapsedTime)\n")
}

public extension NSCharacterSet {
    var characters:[String] {
        var chars = [String]()
        for plane:UInt8 in 0...16 {
            if self.hasMemberInPlane(plane) {
                let p0 = UInt32(plane) << 16
                let p1 = (UInt32(plane) + 1) << 16
                for c:UTF32Char in p0..<p1 {
                    if self.longCharacterIsMember(c) {
                        var c1 = c.littleEndian
                        let s = NSString(bytes: &c1, length: 4, encoding: String.Encoding.utf32LittleEndian.rawValue)!
                        chars.append(String(s))
                    }
                }
            }
        }
        return chars
    }
}

// MARK: -

import Foundation

// https://medium.com/@johnsundell/writing-unit-tests-in-swift-playgrounds-9f5b6cdeb5f7

import XCTest

public class TestObserver: NSObject, XCTestObservation {
    public func testCase(_ testCase: XCTestCase,
                  didFailWithDescription description: String,
                  inFile filePath: String?,
                  atLine lineNumber: Int) {
        assertionFailure(description, line: UInt(lineNumber))
    }
}


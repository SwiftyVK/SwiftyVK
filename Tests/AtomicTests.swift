import Foundation
import XCTest
@testable import SwiftyVK

class AtomicTests: XCTestCase {
    
    func test_wrapAndUnwrap() {
        let atomic = Atomic(1)
        
        atomic.willWrap { value in
            XCTAssertEqual(value, 1)
        }
        atomic.didWrap { value in
            XCTAssertEqual(value, 2)
        }
        
        XCTAssertEqual(atomic|>, 1)
        atomic |< 2
        XCTAssertEqual(atomic|>, 2)
    }
    
    func test_modify_withConcurentIncrement() {
        let atomic = Atomic(NSNumber(integerLiteral: 0))
        
        let group = DispatchGroup()
        
        let cycle: () -> () = {
            DispatchQueue(label: "").async {
                
                for _ in 0..<10 {
                    _ = atomic >< {value in
                        NSNumber(integerLiteral: value.intValue+1)
                    }
                }
                
                group.leave()
            }
        }
        
        for _ in 0..<100 {
            group.enter()
        }
        
        for _ in 0..<100 {
            cycle()
        }

        group.wait()
        XCTAssertEqual(atomic|>.intValue, 1000)
    }
    
    
    func test_perform_withConcurentIncrement() {
        let atomic = Atomic(NSNumber(integerLiteral: 0))
        var notAtomic = 0
        
        let group = DispatchGroup()
        
        let cycle: () -> () = {
            DispatchQueue(label: "").async {
                
                for _ in 0..<10 {
                    atomic <> {value in
                        notAtomic += 1
                    }
                }
                
                group.leave()
            }
        }
        
        for _ in 0..<100 {
            group.enter()
        }
        
        for _ in 0..<100 {
            cycle()
        }
        
        group.wait()
        XCTAssertEqual(notAtomic, 1000)
    }
}

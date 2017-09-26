import XCTest
import FuncKit

enum TestError: Error {
    case error1
    case error2
    case numIsOdd
}

func plus1(num: Int) -> Int {
    return num + 1
}

func plus(num1: Int, num2: Int) -> Int {
    return num1 + num2
}

func divideBy2(num: Int) -> Result<Int> {
    if num % 2 == 0 {
        return .success(num / 2)
    } else {
        return .failure(TestError.numIsOdd)
    }
}

class FuncKitTests: XCTestCase {
    
    // MARK: Functor
    func testMap() {
        let s = plus1 <^> Result.success(5)
        XCTAssertEqual(s.value!, 6)
        
        let f = plus1 <^> Result.failure(TestError.error1)
        guard case .failure(let e) = f else {
            XCTFail()
            return
        }

        XCTAssertEqual(e as! TestError, TestError.error1)
    }
    
    // MARK: Monad
    func testFlatMap() {
        let s = .success(4) >>- divideBy2
        XCTAssertEqual(s.value!, 2)
        
        let f = .success(5) >>- divideBy2
        guard case .failure(let e) = f else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(e as! TestError, TestError.numIsOdd)
        
    }
    
    func testCompose() {
        let function = divideBy2 |> divideBy2
        
        let s = function(8)
        XCTAssertEqual(s.value!, 2)
        
        let f = function(2)
        guard case .failure(let e) = f else {
            XCTFail()
            return
        }
        
        XCTAssertEqual(e as! TestError, TestError.numIsOdd)
    }
    
    // MARK: Applicative

    func testApplicative() {
        let v1 = Result.success(2)
        let v2 = Result.success(3)
        let curriedPlus = curry(plus)
        
        let result = curriedPlus <^> v1 <*> v2
        XCTAssertEqual(result.value!, 5)
    }
    
    // MARK: Curry
    
    func testCurry() {
        let plus8 = curry(plus)(8)
        let ten = plus8(2)
        XCTAssertEqual(10, ten)
    }
    
    static var allTests = [
        ("testMap", testMap),
        ("testFlatMap", testFlatMap),
        ("testCompose", testCompose),
        ("testApplicative", testApplicative),
        ("testCurry", testCurry),
    ]
}

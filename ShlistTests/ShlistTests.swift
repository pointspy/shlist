//
//  ShlistTests.swift
//  ShlistTests
//
//  Created by Pavel Lyskov on 13.04.2020.
//  Copyright © 2020 Pavel Lyskov. All rights reserved.
//

import XCTest
import Overture

class ShlistTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func testPerformingOperation() throws {
        let sam = Sam(name: "")
        let operation = AsyncOperation { update(sam, mut(\Sam.name, "OOOO")) }
        let result = try await(operation.perform)
        
        let res = Sam(name: "OOOO")
        
        
        XCTAssertEqual(result, res)
    }
    
    
}


public struct AsyncOperation<Value> {
    let queue: DispatchQueue = .main
    let closure: () -> Value

    func perform(then handler: @escaping (Value) -> Void) {
        queue.async {
            let value = self.closure()
            handler(value)
        }
    }
}

enum AwaitError: Error {
    case regular
}

extension XCTestCase {
    func await<T>(_ function: (@escaping (T) -> Void) -> Void) throws -> T {
        let expectation = self.expectation(description: "Async call")
        var result: T?

        function() { value in
            result = value
            expectation.fulfill()
        }

        waitForExpectations(timeout: 10)

        guard let unwrappedResult = result else {
            throw AwaitError.regular
        }

        return unwrappedResult
    }
}

extension XCTestCase {
    // We'll add a typealias for our closure types, to make our
    // new method signature a bit easier to read.
    typealias Function<T> = (T) -> Void

    func await<A, R>(_ function: @escaping Function<(A, Function<R>)>,
                     calledWith argument: A) throws -> R {
        return try await { handler in
            function((argument, handler))
        }
    }
}


struct Sam {
    
    var name: String
    
    mutating func set(name: String) {
        self.name = name
    }
}

extension Sam: Equatable {
    
}

@discardableResult
func withName() -> (inout Sam) -> Void {
    return { $0.set(name: "OOOO") }
}



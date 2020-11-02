//
//  XCTestCaseExtensions.swift
//  PredicateKitTests
//
//  Copyright 2020 Faiçal Tchirou
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated
//  documentation files (the "Software"), to deal in the Software without restriction, including without limitation
//  the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and
//  to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or substantial portions of
//  the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE
//  WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS
//  OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
//  OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//

import XCTest

@testable import PredicateKit

extension XCTestCase {
  func expectFatalError(_ test: @escaping () throws -> Void) -> String? {
    let expectation = self.expectation(description: "fatalError")
    var expected: String? = nil

    Functions.fatalError = { message, _, _ in
      expected = message()
      expectation.fulfill()
      return never()
    }

    DispatchQueue.global(qos: .userInitiated).async {
      do {
        try test()
      } catch {
        XCTFail(error.localizedDescription)
        expectation.fulfill()
      }
    }

    wait(for: [expectation], timeout: 5)
    Functions.fatalError = Swift.fatalError
    return expected
  }
}

private func never() -> Never {
  repeat {
    RunLoop.current.run()
  } while (true)
}

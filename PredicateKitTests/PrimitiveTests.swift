//
//  PrimitiveTests.swift
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

import Foundation
import XCTest

@testable import PredicateKit

final class PrimitiveTests: XCTestCase {
  func testBool() {
    XCTAssertEqual(Bool.type, .bool)
  }

  func testInt() {
    XCTAssertEqual(Int.type, .int)
  }

  func testInt8() {
    XCTAssertEqual(Int8.type, .int8)
  }

  func testInt16() {
    XCTAssertEqual(Int16.type, .int16)
  }

  func testInt32() {
    XCTAssertEqual(Int32.type, .int32)
  }
  
  func testInt64() {
    XCTAssertEqual(Int64.type, .int64)
  }
  
  func testUInt() {
    XCTAssertEqual(UInt.type, .uint)
  }

  func testUInt8() {
    XCTAssertEqual(UInt8.type, .uint8)
  }

  func testUInt16() {
    XCTAssertEqual(UInt16.type, .uint16)
  }

  func testUInt32() {
    XCTAssertEqual(UInt32.type, .uint32)
  }
  
  func testUInt64() {
    XCTAssertEqual(UInt64.type, .uint64)
  }

  func testDouble() {
    XCTAssertEqual(Double.type, .double)
  }

  func testFloat() {
    XCTAssertEqual(Float.type, .float)
  }

  func testString() {
    XCTAssertEqual(String.type, .string)
  }

  func testDate() {
    XCTAssertEqual(Date.type, .date)
  }
  
  func testURL() {
    XCTAssertEqual(URL.type, .url)
  }

  func testUUID() {
    XCTAssertEqual(UUID.type, .uuid)
  }

  func testData() {
    XCTAssertEqual(Data.type, .data)
  }

  func testEnum() {
    enum IntEnum: Int, Primitive { case one }
    enum StringEnum: String, Primitive { case one }
    enum DoubleEnum: Double, Primitive { case one }

    XCTAssertEqual(IntEnum.type, .int)
    XCTAssertEqual(StringEnum.type, .string)
    XCTAssertEqual(DoubleEnum.type, .double)
  }

  func testArray() {
    XCTAssertEqual([Int].type, .array(.int))
    XCTAssertEqual([Bool].type, .array(.bool))
    XCTAssertEqual([Int].type, .array(.int))
    XCTAssertEqual([Int8].type, .array(.int8))
    XCTAssertEqual([Int16].type, .array(.int16))
    XCTAssertEqual([Int32].type, .array(.int32))
    XCTAssertEqual([Int64].type, .array(.int64))
    XCTAssertEqual([UInt].type, .array(.uint))
    XCTAssertEqual([UInt8].type, .array(.uint8))
    XCTAssertEqual([UInt16].type, .array(.uint16))
    XCTAssertEqual([UInt32].type, .array(.uint32))
    XCTAssertEqual([UInt64].type, .array(.uint64))
    XCTAssertEqual([Double].type, .array(.double))
    XCTAssertEqual([Float].type, .array(.float))
    XCTAssertEqual([String].type, .array(.string))
    XCTAssertEqual([Date].type, .array(.date))
    XCTAssertEqual([URL].type, .array(.url))
    XCTAssertEqual([UUID].type, .array(.uuid))
    XCTAssertEqual([Data].type, .array(.data))
  }
  
  func testOptional() {
    XCTAssertEqual(Optional<Int>.type, .int)
    XCTAssertEqual(Optional<Bool>.type, .bool)
    XCTAssertEqual(Optional<Int>.type, .int)
    XCTAssertEqual(Optional<Int8>.type, .int8)
    XCTAssertEqual(Optional<Int16>.type, .int16)
    XCTAssertEqual(Optional<Int32>.type, .int32)
    XCTAssertEqual(Optional<Int64>.type, .int64)
    XCTAssertEqual(Optional<UInt>.type, .uint)
    XCTAssertEqual(Optional<UInt8>.type, .uint8)
    XCTAssertEqual(Optional<UInt16>.type, .uint16)
    XCTAssertEqual(Optional<UInt32>.type, .uint32)
    XCTAssertEqual(Optional<UInt64>.type, .uint64)
    XCTAssertEqual(Optional<Double>.type, .double)
    XCTAssertEqual(Optional<Float>.type, .float)
    XCTAssertEqual(Optional<String>.type, .string)
    XCTAssertEqual(Optional<Date>.type, .date)
    XCTAssertEqual(Optional<URL>.type, .url)
    XCTAssertEqual(Optional<UUID>.type, .uuid)
    XCTAssertEqual(Optional<Data>.type, .data)
  }

  func testComparableOptional() {
    let lhs: Int? = 42
    let rhs: Int? = 64

    XCTAssertTrue(lhs < rhs)
    XCTAssertFalse(nil < rhs)
    XCTAssertFalse(lhs < nil)
  }

  func testDefaultComparisonOptions() {
    XCTAssertEqual(UUID.defaultComparisonOptions, .none)
    XCTAssertEqual(Bool.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Int.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Int8.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Int16.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Int32.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Int64.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(UInt.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(UInt8.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(UInt16.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(UInt32.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(UInt64.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Double.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Float.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(String.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Date.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(URL.defaultComparisonOptions, .caseInsensitive)
    XCTAssertEqual(Data.defaultComparisonOptions, .caseInsensitive)
  }
}

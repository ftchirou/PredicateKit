//
//  FetchRequestTests.swift
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

import CoreData
import Foundation
import XCTest

@testable import PredicateKit
import enum PredicateKit.Predicate

final class NSFetchRequestBuilderTests: XCTestCase {

  // MARK: - Request Predicates

  func testLessThanPredicate() throws {
    let request = makeRequest(\Data.count < 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayElementLessThanPredicate() throws {
    let request = makeRequest((\Data.relationships).first(\.count) < 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.predicateFormat, NSPredicate(format: "relationships[FIRST].count <[c] 42").predicateFormat)
  }

  func testLessThanOrEqualPredicate() throws {
    let request = makeRequest(\Data.count <= 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThanOrEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayElementLessThanOrEqualPredicate() throws {
    let request = makeRequest((\Data.relationships).last(\.count) <= 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.predicateFormat, NSPredicate(format: "relationships[LAST].count <=[c] 42").predicateFormat)
  }

  func testEqualityPredicate() throws {
    let request = makeRequest(\Data.text == "Hello, World!")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func testEqualityWithIdentifiable() throws {
    guard let identifiable = makeIdentifiable() else {
      XCTFail("could not initialize IdentifiableData")
      return
    }

    identifiable.id = "42"

    let request = makeRequest(\Data.identifiable == identifiable)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "identifiable.id"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "42"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func testEqualityWithOptionalIdentifiable() throws {
    guard let identifiable = makeIdentifiable() else {
      XCTFail("could not initialize IdentifiableData")
      return
    }

    identifiable.id = "42"

    let request = makeRequest(\Data.optionalIdentifiable == identifiable)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "optionalIdentifiable.id"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "42"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testEqualityWithRawRepresentable() throws {
    let request = makeRequest(\Data.dataType == .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "dataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: DataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testLessThanWithRawRepresentable() throws {
    let request = makeRequest(\Data.dataType < .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "dataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: DataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testLessThanOrEqualWithRawRepresentable() throws {
    let request = makeRequest(\Data.dataType <= .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "dataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: DataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThanOrEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testGreaterThanWithRawRepresentable() throws {
    let request = makeRequest(\Data.dataType > .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "dataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: DataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testGreaterThanOrEqualWithRawRepresentable() throws {
    let request = makeRequest(\Data.dataType >= .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "dataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: DataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThanOrEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testEqualityWithRawRepresentableConformingToPrimitive() throws {
    let request = makeRequest(\Data.primitiveDataType == .three)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "primitiveDataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: PrimitiveDataType.three.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testLessThanWithRawRepresentableConformingToPrimitive() throws {
    let request = makeRequest(\Data.primitiveDataType < .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "primitiveDataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: PrimitiveDataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testLessThanOrEqualWithRawRepresentableConformingToPrimitive() throws {
    let request = makeRequest(\Data.primitiveDataType <= .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "primitiveDataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: PrimitiveDataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThanOrEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testGreaterThanWithRawRepresentableConformingToPrimitive() throws {
    let request = makeRequest(\Data.primitiveDataType > .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "primitiveDataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: PrimitiveDataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testGreaterThanOrEqualWithRawRepresentableConformingToPrimitive() throws {
    let request = makeRequest(\Data.primitiveDataType >= .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "primitiveDataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: PrimitiveDataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThanOrEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayElementEqualPredicate() throws {
    let request = makeRequest((\Data.relationships).last(\.count) == 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.predicateFormat, NSPredicate(format: "relationships[LAST].count ==[c] 42").predicateFormat)
  }

  func testNotEqualPredicate() throws {
    let request = makeRequest(\Data.text != "Hello, World!")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .notEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func testNotEqualWithIdentifiable() throws {
    guard let identifiable = makeIdentifiable() else {
      XCTFail("could not initialize IdentifiableData")
      return
    }

    identifiable.id = "42"

    let request = makeRequest(\Data.identifiable != identifiable)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "identifiable.id"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "42"))
    XCTAssertEqual(comparison.predicateOperatorType, .notEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func testNotEqualWithOptionalIdentifiable() throws {
    guard let identifiable = makeIdentifiable() else {
      XCTFail("could not initialize IdentifiableData")
      return
    }

    identifiable.id = "42"

    let request = makeRequest(\Data.optionalIdentifiable != identifiable)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "optionalIdentifiable.id"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "42"))
    XCTAssertEqual(comparison.predicateOperatorType, .notEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testNotEqualWithRawRepresentable() throws {
    let request = makeRequest(\Data.dataType != .two)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "dataType"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: DataType.two.rawValue))
    XCTAssertEqual(comparison.predicateOperatorType, .notEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayElementNotEqualPredicate() throws {
    let request = makeRequest((\Data.relationships).last(\.count) != 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.predicateFormat, NSPredicate(format: "relationships[LAST].count !=[c] 42").predicateFormat)
  }

  func testGreaterThanOrEqualPredicate() throws {
    let request = makeRequest(\Data.count >= 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThanOrEqualTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayElementGreaterThanOrEqualPredicate() throws {
    let request = makeRequest((\Data.relationships).at(index: 3, \.count) >= 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.predicateFormat, NSPredicate(format: "relationships[3].count >=[c] 42").predicateFormat)
  }

  func testGreaterThanPredicate() throws {
    let request = makeRequest(\Data.count > 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayElementGreaterEqualPredicate() throws {
    let request = makeRequest((\Data.relationships).at(index: 0, \.count) > 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.predicateFormat, NSPredicate(format: "relationships[0].count >[c] 42").predicateFormat)
  }
  
  func testBetweenPredicate() throws {
    let request = makeRequest((\Data.count).between(21...42))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: [21, 42]))
    XCTAssertEqual(comparison.predicateOperatorType, .between)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testInPredicate() throws {
    let request = makeRequest((\Data.text).in("hello", "world"))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: ["hello", "world"]))
    XCTAssertEqual(comparison.predicateOperatorType, .in)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }
  
  func testInCaseInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).in(["hello", "world"], .caseInsensitive))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: ["hello", "world"]))
    XCTAssertEqual(comparison.predicateOperatorType, .in)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testInDiacriticInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).in(["hello", "world"], .diacriticInsensitive))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: ["hello", "world"]))
    XCTAssertEqual(comparison.predicateOperatorType, .in)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testInNormalizedPredicate() throws {
    let request = makeRequest((\Data.text).in(["hello", "world"], .normalized))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: ["hello", "world"]))
    XCTAssertEqual(comparison.predicateOperatorType, .in)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }

  func testIsEqualToCaseInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).isEqualTo("lorem", .caseInsensitive))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testIsEqualToDiacriticInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).isEqualTo("lorem", .diacriticInsensitive))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testIsEqualToNormalizedPredicate() throws {
    let request = makeRequest((\Data.text).isEqualTo("lorem", .normalized))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }

  func testBeginsWithPredicate() throws {
    let request = makeRequest((\Data.text).beginsWith("lorem"))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .beginsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testBeginsWithCaseInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).beginsWith("lorem", .caseInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .beginsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testBeginsWithDiacriticInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).beginsWith("lorem", .diacriticInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .beginsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testBeginsWithNormalizedPredicate() throws {
    let request = makeRequest((\Data.text).beginsWith("lorem", .normalized))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .beginsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }
  
  func testContainsPredicate() throws {
    let request = makeRequest((\Data.text).contains("lorem"))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .contains)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testContainsCaseInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).contains("lorem", .caseInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .contains)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testContainsDiacriticInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).contains("lorem", .diacriticInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .contains)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testContainsNormalizedPredicate() throws {
    let request = makeRequest((\Data.text).contains("lorem", .normalized))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .contains)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }
  
  func testEndsWithPredicate() throws {
    let request = makeRequest((\Data.text).endsWith("lorem"))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .endsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }
  
  func testEndsWithCaseInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).endsWith("lorem", .caseInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .endsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testEndsWithDiacriticInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).endsWith("lorem", .diacriticInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .endsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testEndsWithNormalizedPredicate() throws {
    let request = makeRequest((\Data.text).endsWith("lorem", .normalized))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .endsWith)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }
  
  func testLikePredicate() throws {
    let request = makeRequest((\Data.text).like("lorem"))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .like)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }
  
  func testLikeCaseInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).like("lorem", .caseInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .like)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testLikeDiacriticInsensitivePredicate() throws {
    let request = makeRequest((\Data.text).like("lorem", .diacriticInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .like)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testLikeNormalizedPredicate() throws {
    let request = makeRequest((\Data.text).like("lorem", .normalized))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "lorem"))
    XCTAssertEqual(comparison.predicateOperatorType, .like)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }
  
  func testMatchesPredicate() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]", options: [])
    let request = makeRequest((\Data.text).matches(regexp))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "[a-z]"))
    XCTAssertEqual(comparison.predicateOperatorType, .matches)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testMatchesCaseInsensitivePredicate() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]", options: [])
    let request = makeRequest((\Data.text).matches(regexp, .caseInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "[a-z]"))
    XCTAssertEqual(comparison.predicateOperatorType, .matches)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .caseInsensitive)
  }

  func testMatchesDiacriticInsensitivePredicate() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]", options: [])
    let request = makeRequest((\Data.text).matches(regexp, .diacriticInsensitive))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "[a-z]"))
    XCTAssertEqual(comparison.predicateOperatorType, .matches)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
  }

  func testMatchesNormalizedPredicate() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]", options: [])
    let request = makeRequest((\Data.text).matches(regexp, .normalized))
    let builder = makeRequestBuilder()
  
    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "[a-z]"))
    XCTAssertEqual(comparison.predicateOperatorType, .matches)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    XCTAssertEqual(comparison.options, .normalized)
  }

  func testAnyModifierOnComparisonPredicate() throws {
    let request = makeRequest((\Data.relationships).any(\.text) == "Hello, World!")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "relationships.text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .any)
  }
  
  func testAllModifierOnComparisonPredicate() throws {
    let request = makeRequest((\Data.relationships).all(\.text) == "Hello, World!")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "relationships.text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .all)
  }
  
  func testNoneModifierOnComparisonPredicate() throws {
    let request = makeRequest((\Data.relationships).none(\.text) == "Hello, World!")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let predicate = try XCTUnwrap(result.predicate as? NSCompoundPredicate)
    XCTAssertEqual(predicate.compoundPredicateType, .not)
    
    let comparison = try XCTUnwrap(predicate.subpredicates.first as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "relationships.text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .any)
  }

  func testAndPredicate() throws {
    let request = makeRequest(\Data.text == "Hello, World!" && \Data.count < 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let predicate = try XCTUnwrap(result.predicate as? NSCompoundPredicate)
    XCTAssertEqual(predicate.compoundPredicateType, .and)

    let lhs = try XCTUnwrap(predicate.subpredicates.first as? NSComparisonPredicate)
    XCTAssertEqual(lhs.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(lhs.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(lhs.predicateOperatorType, .equalTo)
    XCTAssertEqual(lhs.comparisonPredicateModifier, .direct)

    let rhs = try XCTUnwrap(predicate.subpredicates.last as? NSComparisonPredicate)
    XCTAssertEqual(rhs.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(rhs.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(rhs.predicateOperatorType, .lessThan)
    XCTAssertEqual(rhs.comparisonPredicateModifier, .direct)
  }
  
  func testOrPredicate() throws {
    let request = makeRequest(\Data.text == "Hello, World!" || \Data.count < 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let predicate = try XCTUnwrap(result.predicate as? NSCompoundPredicate)
    XCTAssertEqual(predicate.compoundPredicateType, .or)

    let lhs = try XCTUnwrap(predicate.subpredicates.first as? NSComparisonPredicate)
    XCTAssertEqual(lhs.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(lhs.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(lhs.predicateOperatorType, .equalTo)
    XCTAssertEqual(lhs.comparisonPredicateModifier, .direct)

    let rhs = try XCTUnwrap(predicate.subpredicates.last as? NSComparisonPredicate)
    XCTAssertEqual(rhs.leftExpression, NSExpression(forKeyPath: "count"))
    XCTAssertEqual(rhs.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(rhs.predicateOperatorType, .lessThan)
    XCTAssertEqual(rhs.comparisonPredicateModifier, .direct)
  }
  
  func testNotPredicate() throws {
    let request = makeRequest(!(\Data.text == "Hello, World!"))
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let predicate = try XCTUnwrap(result.predicate as? NSCompoundPredicate)
    XCTAssertEqual(predicate.compoundPredicateType, .not)

    let lhs = try XCTUnwrap(predicate.subpredicates.first as? NSComparisonPredicate)
    XCTAssertEqual(lhs.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(lhs.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(lhs.predicateOperatorType, .equalTo)
    XCTAssertEqual(lhs.comparisonPredicateModifier, .direct)
  }

  func testArrayIndexComparison() throws {
    let request = makeRequest((\Data.tags).at(index: 4) == "one")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(format: "tags[4]"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "one"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }
  
  func testArrayFirstComparison() throws {
    let request = makeRequest((\Data.tags).first == "one")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(format: "tags[FIRST]"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "one"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayLastComparison() throws {
    let request = makeRequest((\Data.tags).last == "one")
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(format: "tags[LAST]"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "one"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }
  
  func testArraySizeComparison() throws {
    let request = makeRequest((\Data.tags).size == 5)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(format: "tags[SIZE]"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 5))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testAverageFunctionComparison() throws {
    let request = makeRequest((\Data.stocks).average > 35.0)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression.function, "average:")
    XCTAssertEqual(comparison.leftExpression.arguments, [NSExpression(forKeyPath: "stocks")])
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 35.0))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }
  
  func testSumFunctionComparison() throws {
    let request = makeRequest((\Data.stocks).sum > 125.0)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression.function, "sum:")
    XCTAssertEqual(comparison.leftExpression.arguments, [NSExpression(forKeyPath: "stocks")])
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 125.0))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }
  
  func testModeFunctionComparison() throws {
    let request = makeRequest((\Data.stocks).mode < 20.0)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression.function, "mode:")
    XCTAssertEqual(comparison.leftExpression.arguments, [NSExpression(forKeyPath: "stocks")])
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 20.0))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testMinFunctionComparison() throws {
    let request = makeRequest((\Data.stocks).min == 31.4)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression.function, "min:")
    XCTAssertEqual(comparison.leftExpression.arguments, [NSExpression(forKeyPath: "stocks")])
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 31.4))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }
  
  func testMaxFunctionComparison() throws {
    let request = makeRequest((\Data.stocks).max == 86.5)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression.function, "max:")
    XCTAssertEqual(comparison.leftExpression.arguments, [NSExpression(forKeyPath: "stocks")])
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 86.5))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testSubqueryComparison() throws {
    let request = makeRequest(all(\Data.relationships, where: \Relationship.text == "Hello, World!").count == 42)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression.function, "count:")
    XCTAssertEqual(comparison.leftExpression.arguments, [
      NSExpression(
        forSubquery: NSExpression(forKeyPath: "relationships"),
        usingIteratorVariable: "x",
        predicate: NSComparisonPredicate(
          leftExpression: NSExpression(forKeyPath: "$x.text"),
          rightExpression: NSExpression(forConstantValue: "Hello, World!"),
          modifier: .direct,
          type: .equalTo,
          options: .caseInsensitive
        )
      )
    ])
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  // MARK: - Request Modifiers

  func testSortedByWithDefaultOrder() throws {
    let request = makeRequest((\Data.text).contains("world"))
      .sorted(by: \.count)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let sortDescriptors = try XCTUnwrap(result.sortDescriptors)
    XCTAssertEqual(sortDescriptors.count, 1)
    XCTAssertEqual(sortDescriptors.first?.key, "count")
    XCTAssertTrue(sortDescriptors.first?.ascending ?? false)
  }

  func testSortedByWithSpecificOrder() throws {
    let request = makeRequest((\Data.text).contains("world"))
      .sorted(by: \.count, .descending)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let sortDescriptors = try XCTUnwrap(result.sortDescriptors)
    XCTAssertEqual(sortDescriptors.count, 1)
    XCTAssertEqual(sortDescriptors.first?.key, "count")
    XCTAssertFalse(sortDescriptors.first?.ascending ?? true)
  }

  func testMultipleSortedByModifiers() throws {
    let request = makeRequest((\Data.text).contains("world"))
      .sorted(by: \.count, .descending)
      .sorted(by: \.creationDate, .ascending)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let sortDescriptors = try XCTUnwrap(result.sortDescriptors)
    XCTAssertEqual(sortDescriptors.count, 2)
    XCTAssertEqual(sortDescriptors.first?.key, "count")
    XCTAssertFalse(sortDescriptors.first?.ascending ?? true)
    XCTAssertEqual(sortDescriptors.last?.key, "creationDate")
    XCTAssertTrue(sortDescriptors.last?.ascending ?? false)
  }

  func testSortedByWithCustomComparator() throws {
    let comparator: (Data, Data) -> ComparisonResult = { lhs, rhs in
      return .orderedAscending
    }

    let request = makeRequest((\Data.text).contains("world"))
      .sorted(by: \.count, using: comparator)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let sortDescriptors = try XCTUnwrap(result.sortDescriptors)
    XCTAssertEqual(sortDescriptors.count, 1)
    XCTAssertEqual(sortDescriptors.first?.key, "count")
    XCTAssertTrue(sortDescriptors.first?.ascending ?? false)
    XCTAssertEqual(sortDescriptors.first?.comparator(Data(), Data()), .orderedAscending)
  }

  func testSortedByComparatorSortsByDefaultIfArgumentsAreNotOfTheRightType() throws {
    let comparator: (Data, Data) -> ComparisonResult = { lhs, rhs in
      return .orderedAscending
    }

    let request = makeRequest((\Data.text).contains("world"))
      .sorted(by: \.count, using: comparator)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let sortDescriptors = try XCTUnwrap(result.sortDescriptors)
    XCTAssertEqual(sortDescriptors.count, 1)
    XCTAssertEqual(sortDescriptors.first?.key, "count")
    XCTAssertTrue(sortDescriptors.first?.ascending ?? false)
    XCTAssertEqual(sortDescriptors.first?.comparator(21, 42), .default)
  }

  func testLimitModifier() throws {
    let request = makeRequest(\Data.text == "Hello, World!")
      .limit(100)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertEqual(result.fetchLimit, 100)
  }

  func testOffsetModifier() throws {
    let request = makeRequest(\Data.text == "Hello, World!")
      .limit(100)
      .offset(50)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertEqual(result.fetchLimit, 100)
    XCTAssertEqual(result.fetchOffset, 50)
  }

  func testBatchSizeModifier() throws {
    let request = makeRequest(\Data.text == "Hello, World!")
      .batchSize(20)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertEqual(result.fetchBatchSize, 20)
  }

  func testPrefetchingModifier() throws {
    let request = makeRequest(\Data.count == 42)
      .prefetchingRelationships(\Data.relationship)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let propertiesToPrefetch = try XCTUnwrap(result.relationshipKeyPathsForPrefetching)
    XCTAssertEqual(propertiesToPrefetch, ["relationship"])
  }

  func testIncludingPendingChangesModifier() throws {
    let request = makeRequest(\Data.creationDate == Date())
      .includingPendingChanges(false)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertFalse(result.includesPendingChanges)
  }

  func testFromStoresModifier() throws {
    let store = DataStore()
    let request = makeRequest((\Data.stocks).count == 5)
      .fromStores(store)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertEqual(result.affectedStores, [store])
  }
  
  func testFetchingOnlyModifier() throws {
    let request = makeRequest(\Data.count == 42)
      .fetchingOnly(\Data.text, \Data.count)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let propertiesToPrefetch = try XCTUnwrap(result.propertiesToFetch as? [String])
    XCTAssertEqual(propertiesToPrefetch, ["text", "count"])
  }

  func testReturningDistinctResults() throws {
    let request = makeRequest(\Data.count > 5)
      .returningDistinctResults(true)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertTrue(result.returnsDistinctResults)
  }

  func testGroupByModifier() throws {
    let request = makeRequest(\Data.text == "Hello, World!")
      .groupBy(\Data.count)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let propertiesToGroupBy = try XCTUnwrap(result.propertiesToGroupBy as? [String])
    XCTAssertEqual(propertiesToGroupBy, ["count"])
  }

  func testRefreshingRefetchedObjectsModifier() throws {
    let request = makeRequest((\Data.tags).first == "tag")
      .refreshingRefetchedObjects(true)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertTrue(result.shouldRefreshRefetchedObjects)
  }

  func testHavingPredicateModifier() throws {
    let request = makeRequest(\Data.text == "Hello, World!")
      .groupBy(\Data.count)
      .having((\Data.tags).size > 5)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    let havingPredicate = try XCTUnwrap(result.havingPredicate)
    let comparison = try XCTUnwrap(havingPredicate as? NSComparisonPredicate)

    XCTAssertEqual(comparison.leftExpression, NSExpression(format: "tags[SIZE]"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 5))
    XCTAssertEqual(comparison.predicateOperatorType, .greaterThan)
  }

  func testIncludingSubentitiesModifier() throws {
    let request = makeRequest(\Data.relationship.text == "Hello, World!")
      .includingSubentities(false)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertFalse(result.includesSubentities)
  }

  func testReturningObjectsAsFaultsModifier() throws {
    let request = makeRequest(\Data.count < 42)
      .returningObjectsAsFaults(true)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)
    XCTAssertTrue(result.returnsObjectsAsFaults)
  }

  // MARK: - Fatal Errors

  func testFatalErrorOccursWhenKeyPathDoesNotRepresentAValidProperty() throws {
    let request = makeRequest(\Data.tags[0].isEmpty == true)
    let builder = makeRequestBuilder()

    let fatalError = try XCTUnwrap(expectFatalError {
      let _: NSFetchRequest<Data> = builder.makeRequest(from: request)
    })

    XCTAssertTrue(fatalError.contains("Could not create a string representation of the key path"))
  }

  func testFatalErrorOccursWhenExpressionIsNotNSExpressionConvertible() throws {
    struct Path<Root, Value>: Expression {
    }

    let request = makeRequest(Path() == "/dev/null")
    let builder = makeRequestBuilder()

    let fatalError = try XCTUnwrap(expectFatalError {
      let _: NSFetchRequest<NSManagedObject> = builder.makeRequest(from: request)
    })

    XCTAssertTrue(fatalError.contains("does not conform to NSExpressionConvertible"))
  }

  func testObjectNilEqualityPredicate() throws {
    let request = makeRequest(\Data.optionalRelationship == nil)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "optionalRelationship"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: NSNull()))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testArrayNilEqualityPredicate() throws {
    let request = makeRequest(\Data.optionalRelationships == nil)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "optionalRelationships"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: NSNull()))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testNestedPrimitiveNilEqualityPredicate() throws {
    let request = makeRequest(\Data.optionalRelationship?.text == nil)
    let builder = makeRequestBuilder()

    let result: NSFetchRequest<Data> = builder.makeRequest(from: request)

    let comparison = try XCTUnwrap(result.predicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "optionalRelationship.text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: NSNull()))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  private func makeIdentifiable() -> IdentifiableData? {
    guard
      let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: NSFetchRequestBuilderTests.self)])
    else {
      return nil
    }

    let container = makePersistentContainer(with: model)

    guard let identifiable = NSEntityDescription.insertNewObject(
      forEntityName: "IdentifiableData",
      into: container.viewContext
    ) as? IdentifiableData else {
      return nil
    }

    return identifiable
  }
}

// MARK: -

private class Data: NSManagedObject {
  @NSManaged var text: String
  @NSManaged var count: Int
  @NSManaged var tags: [String]
  @NSManaged var stocks: [Double]
  @NSManaged var creationDate: Date
  @NSManaged var relationship: Relationship
  @NSManaged var relationships: [Relationship]
  @NSManaged var optionalRelationship: Relationship?
  @NSManaged var optionalRelationships: [Relationship]?
  @NSManaged var identifiable: IdentifiableData
  @NSManaged var optionalIdentifiable: IdentifiableData?
  @NSManaged var dataType: DataType
  @NSManaged var primitiveDataType: PrimitiveDataType
}

private class Relationship: NSManagedObject {
  @NSManaged var text: String
  @NSManaged var stocks: [Double]
  @NSManaged var count: Int
}

@objc private enum DataType: Int {
  case zero
  case one
  case two
  case three
}

@objc private enum PrimitiveDataType: Int, Primitive {
  case zero
  case one
  case two
  case three
}

private class DataStore: NSAtomicStore {
  init(_ value: Bool = false) {
    super.init(
      persistentStoreCoordinator: nil,
      configurationName: nil,
      at: URL(string: "https://google.com")!,
      options: nil
    )
  }
}

class IdentifiableData: NSManagedObject, Identifiable {
  @NSManaged var id: String
}

private func makeRequest<T: NSManagedObject>(_ predicate: Predicate<T>) -> FetchRequest<T> {
  .init(context: NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType), predicate: predicate)
}

private func makeRequestBuilder(
  comparisonOptions: NSComparisonPredicate.Options = .caseInsensitive
) -> NSFetchRequestBuilder {
  .init(entityName: "")
}

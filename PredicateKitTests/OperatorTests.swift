//
//  OperatorTests.swift
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
import enum PredicateKit.Predicate

final class OperatorTests: XCTestCase {
  
  // MARK: - <

  func testKeyPathLessThanPrimitive() throws {
    let predicate = \Data.count < 42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count < 42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .lessThan)
    XCTAssertEqual(value, 42)
  }

  func testFunctionLessThanPrimitive() throws {
    let predicate = (\Data.tags).count < 20

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.count < 20 should result in a comparison")
      return
    }

    guard let function = comparison.expression.as(Function<KeyPath<Data, [String]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a function")
      return
    }

    guard case let .count(keyPath) = function else {
      XCTFail("the function should be count:")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(comparison.operator, .lessThan)
    XCTAssertEqual(value, 20)
  }
  
  func testIndexLessThanPrimitive() throws {
    let predicate = (\Data.stocks).first < 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.first < 35.0 should result in a comparison")
      return
    }

    guard let index = comparison.expression.as(Index<KeyPath<Data, [Double]>>.self) else {
      XCTFail("the left side of the comparison should be an array element")
      return
    }

    guard case let .first(keyPath) = index else {
      XCTFail("the element should be 'first'")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath, \Data.stocks)
    XCTAssertEqual(comparison.operator, .lessThan)
    XCTAssertEqual(value, 35.0)
  }

  func testArrayElementKeyPathLessThanPrimitive() throws {
    let predicate = (\Data.relationships).at(index: 4, \.count) < 5

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships[4].count < 5 should result in a comparison")
      return
    }

    guard
      let keyPath = comparison
        .expression
        .as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self)
    else {
      XCTFail("the left side of the comparison should be an array element key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .index(4))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .lessThan)
    XCTAssertEqual(value, 5)
  }

  // MARK: - <=
  
  func testKeyPathLessThanOrEqualPrimitive() throws {
    let predicate = \Data.count <= 42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count <= 42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .lessThanOrEqual)
    XCTAssertEqual(value, 42)
  }

  func testFunctionLessThanOrEqualPrimitive() throws {
    let predicate = (\Data.tags).count <= 20

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.count <= 20 should result in a comparison")
      return
    }

    guard let function = comparison.expression.as(Function<KeyPath<Data, [String]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a function")
      return
    }

    guard case let .count(keyPath) = function else {
      XCTFail("the function should be count:")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(comparison.operator, .lessThanOrEqual)
    XCTAssertEqual(value, 20)
  }
  
  func testArrayElementLessThanOrEqualPrimitive() throws {
    let predicate: Predicate<Data> = (\Data.stocks).first <= 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.first <= 35.0 should result in a comparison")
      return
    }

    guard let index = comparison.expression.as(Index<KeyPath<Data, [Double]>>.self) else {
      XCTFail("the left side of the comparison should be an array element")
      return
    }

    guard case let .first(keyPath) = index else {
      XCTFail("the element should be 'first'")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath, \Data.stocks)
    XCTAssertEqual(comparison.operator, .lessThanOrEqual)
    XCTAssertEqual(value, 35.0)
  }

  func testArrayElementKeyPathLessThanOrEqualPrimitive() throws {
    let predicate: Predicate<Data> = (\Data.relationships).last(\.count) <= 5

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.count <=5 should result in a comparison")
      return
    }

    guard
      let keyPath = comparison
        .expression
        .as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self)
    else {
      XCTFail("the left side of the comparison should be an array element key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .lessThanOrEqual)
    XCTAssertEqual(value, 5)
  }

  // MARK: - ==

  func testKeyPathEqualPrimitive() throws {
    let predicate = \Data.count == 42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count == 42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 42)
  }

  @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func testKeyPathEqualIdentifiable() throws {
    struct Data {
      let identifiable: IdentifiableData
    }

    struct IdentifiableData: Identifiable, Equatable {
      let id: String
    }

    let predicate = \Data.identifiable == IdentifiableData(id: "1")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("identifiable.id == 1 should result in a comparison")
      return
    }

    guard
      let expression = comparison.expression.as(ObjectIdentifier<KeyPath<Data, IdentifiableData>, String>.self)
    else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? IdentifiableData.ID)

    XCTAssertEqual(expression.root, \Data.identifiable)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, "1")
  }

  func testKeyPathEqualRawRepresentable() throws {
    struct Data {
      let rawRepresentable: RawRepresentableValue
    }

    enum RawRepresentableValue: Int {
      case zero
      case one
    }

    let predicate = \Data.rawRepresentable == .zero

    guard case let .comparison(comparison) = predicate else {
      XCTFail("rawRepresentable == .zero should result in a comparison")
      return
    }

    guard
      let expression = comparison.expression.as(KeyPath<Data, RawRepresentableValue>.self)
    else {
      XCTFail("the left side of the comparison should be a key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? RawRepresentableValue.RawValue)

    XCTAssertEqual(expression, \Data.rawRepresentable)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 0)
  }

  func testOptionalKeyPathEqualToNil() throws {
    let predicate: Predicate<Data> = \Data.optionalRelationship == nil

    guard case let .comparison(comparison) = predicate else {
      XCTFail("optionalRelationship == nil should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Relationship?>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.optionalRelationship)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertNotNil(comparison.value as? Nil)
  }

  func testOptionalArrayKeyPathEqualToNil() throws {
    let predicate: Predicate<Data> = \Data.optionalRelationships == nil

    guard case let .comparison(comparison) = predicate else {
      XCTFail("optionalRelationships == nil should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, [Relationship]?>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.optionalRelationships)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertNotNil(comparison.value as? Nil)
  }

  func testFunctionEqualPrimitive() throws {
    let predicate = (\Data.tags).count == 20

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.count == 20 should result in a comparison")
      return
    }

    guard let function = comparison.expression.as(Function<KeyPath<Data, [String]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a function")
      return
    }

    guard case let .count(keyPath) = function else {
      XCTFail("the function should be count:")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 20)
  }
  
  func testArrayElementEqualPrimitive() throws {
    let predicate = (\Data.stocks).first == 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.first == 35.0 should result in a comparison")
      return
    }

    guard let index = comparison.expression.as(Index<KeyPath<Data, [Double]>>.self) else {
      XCTFail("the left side of the comparison should be an array element")
      return
    }

    guard case let .first(keyPath) = index else {
      XCTFail("the function should be 'first'")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath, \Data.stocks)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 35.0)
  }

  func testArrayElementKeyPathEqualPrimitive() throws {
    let predicate = (\Data.relationships).first(\.count) == 5

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.count == 5 should result in a comparison")
      return
    }

    guard
      let keyPath = comparison
        .expression
        .as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self)
    else {
      XCTFail("the left side of the comparison should be an array element key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 5)
  }
  
  // MARK: - !=

  func testKeyPathNotEqualPrimitive() throws {
    let predicate = \Data.count != 42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count != 42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertEqual(value, 42)
  }

  func testFunctionNotEqualPrimitive() throws {
    let predicate = (\Data.tags).count != 20

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.count != 20 should result in a comparison")
      return
    }

    guard let function = comparison.expression.as(Function<KeyPath<Data, [String]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a function")
      return
    }

    guard case let .count(keyPath) = function else {
      XCTFail("the function should be count:")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertEqual(value, 20)
  }
  
  func testArrayElementNotEqualPrimitive() throws {
    let predicate = (\Data.stocks).first != 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.first != 35.0 should result in a comparison")
      return
    }

    guard let index = comparison.expression.as(Index<KeyPath<Data, [Double]>>.self) else {
      XCTFail("the left side of the comparison should be an array element")
      return
    }

    guard case let .first(keyPath) = index else {
      XCTFail("the function should be 'first'")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath, \Data.stocks)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertEqual(value, 35.0)
  }

  func testArrayElementKeyPathNotEqualPrimitive() throws {
    let predicate = (\Data.relationships).first(\.count) != 5

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.count != 5 should result in a comparison")
      return
    }

    guard
      let keyPath = comparison
        .expression
        .as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self)
    else {
      XCTFail("the left side of the comparison should be an array element key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertEqual(value, 5)
  }

  @available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
  func testKeyPathNotEqualIdentifiable() throws {
    struct Data {
      let identifiable: IdentifiableData
    }

    struct IdentifiableData: Identifiable, Equatable {
      let id: String
    }

    let predicate = \Data.identifiable != IdentifiableData(id: "1")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("identifiable.id != 1 should result in a comparison")
      return
    }

    guard
      let expression = comparison.expression.as(ObjectIdentifier<KeyPath<Data, IdentifiableData>, String>.self)
    else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? IdentifiableData.ID)

    XCTAssertEqual(expression.root, \Data.identifiable)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertEqual(value, "1")
  }

  func testKeyPathNotEqualRawRepresentable() throws {
    struct Data {
      let rawRepresentable: RawRepresentableValue
    }

    enum RawRepresentableValue: Int {
      case zero
      case one
    }

    let predicate = \Data.rawRepresentable != .zero

    guard case let .comparison(comparison) = predicate else {
      XCTFail("rawRepresentable != .zero should result in a comparison")
      return
    }

    guard
      let expression = comparison.expression.as(KeyPath<Data, RawRepresentableValue>.self)
    else {
      XCTFail("the left side of the comparison should be a key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? RawRepresentableValue.RawValue)

    XCTAssertEqual(expression, \Data.rawRepresentable)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertEqual(value, 0)
  }

  func testOptionalKeyPathNotEqualToNil() throws {
    let predicate: Predicate<Data> = \Data.optionalRelationship != nil

    guard case let .comparison(comparison) = predicate else {
      XCTFail("optionalRelationship != nil should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Relationship?>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.optionalRelationship)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertNotNil(comparison.value as? Nil)
  }

  func testOptionalArrayKeyPathNotEqualToNil() throws {
    let predicate: Predicate<Data> = \Data.optionalRelationships != nil

    guard case let .comparison(comparison) = predicate else {
      XCTFail("optionalRelationships != nil should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, [Relationship]?>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.optionalRelationships)
    XCTAssertEqual(comparison.operator, .notEqual)
    XCTAssertNotNil(comparison.value as? Nil)
  }

  // MARK: - >=

  func testKeyPathGreaterThanOrEqualPrimitive() throws {
    let predicate = \Data.count >= 42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count >= 42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .greaterThanOrEqual)
    XCTAssertEqual(value, 42)
  }

  func testFunctionGreaterThanOrEqualPrimitive() throws {
    let predicate = (\Data.tags).count >= 20

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.count >= 20 should result in a comparison")
      return
    }

    guard let function = comparison.expression.as(Function<KeyPath<Data, [String]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a function")
      return
    }

    guard case let .count(keyPath) = function else {
      XCTFail("the function should be count:")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(comparison.operator, .greaterThanOrEqual)
    XCTAssertEqual(value, 20)
  }
  
  func testArrayElementGreaterThanOrEqualPrimitive() throws {
    let predicate: Predicate<Data> = (\Data.stocks).first >= 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.first >= 35.0 should result in a comparison")
      return
    }

    guard let index = comparison.expression.as(Index<KeyPath<Data, [Double]>>.self) else {
      XCTFail("the left side of the comparison should be an array element")
      return
    }

    guard case let .first(keyPath) = index else {
      XCTFail("the array element should be 'first'")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath, \Data.stocks)
    XCTAssertEqual(comparison.operator, .greaterThanOrEqual)
    XCTAssertEqual(value, 35.0)
  }

  func testArrayElementKeyPathGreaterThanOrEqualPrimitive() throws {
    let predicate = (\Data.relationships).last(\.count) >= 5

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.count == 5 should result in a comparison")
      return
    }

    guard
      let keyPath = comparison
        .expression
        .as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self)
    else {
      XCTFail("the left side of the comparison should be an array element key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .greaterThanOrEqual)
    XCTAssertEqual(value, 5)
  }

  // MARK: - >

  func testKeyPathGreaterThanPrimitive() throws {
    let predicate = \Data.count > 42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count > 42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .greaterThan)
    XCTAssertEqual(value, 42)
  }

  func testFunctionGreaterThanPrimitive() throws {
    let predicate = (\Data.tags).count > 20

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.count > 20 should result in a comparison")
      return
    }

    guard let function = comparison.expression.as(Function<KeyPath<Data, [String]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a function")
      return
    }

    guard case let .count(keyPath) = function else {
      XCTFail("the function should be count:")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(comparison.operator, .greaterThan)
    XCTAssertEqual(value, 20)
  }
  
  func testArrayElementGreaterThanPrimitive() throws {
    let predicate = (\Data.stocks).first > 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("tags.first > 35.0 should result in a comparison")
      return
    }

    guard let index = comparison.expression.as(Index<KeyPath<Data, [Double]>>.self) else {
      XCTFail("the left side of the comparison should be an array element")
      return
    }

    guard case let .first(keyPath) = index else {
      XCTFail("the function should be 'first'")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath, \Data.stocks)
    XCTAssertEqual(comparison.operator, .greaterThan)
    XCTAssertEqual(value, 35.0)
  }

  func testArrayElementKeyPathGreaterThanPrimitive() throws {
    let predicate: Predicate<Data> = (\Data.relationships).at(index: 2, \.count) > 5

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.count == 5 should result in a comparison")
      return
    }

    guard
      let keyPath = comparison
        .expression
        .as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self)
    else {
      XCTFail("the left side of the comparison should be an array element key path")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .index(2))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .greaterThan)
    XCTAssertEqual(value, 5)
  }

  // MARK: - beginsWith

  func testBeginsWith() throws {
    let predicate = (\Data.text).beginsWith("Hello, World!")
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .beginsWith)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testArrayElementKeyPathBeginsWith() throws {
    let predicate = (\Data.relationships).last(\.text).beginsWith("Hello, World!")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be an array element key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .beginsWith)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testBeginsWithCaseInsensitive() throws {
    let predicate = (\Data.text).beginsWith("Hello, World!", .caseInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .beginsWith)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testBeginsWithDiacriticInsensitive() throws {
    let predicate = (\Data.text).beginsWith("Hello, World!", .diacriticInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .beginsWith)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testBeginsWithNormalized() throws {
    let predicate = (\Data.text).beginsWith("Hello, World!", .normalized)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .beginsWith)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, "Hello, World!")
  }

  // MARK: - contains
  
  func testKeyPathContains() throws {
    let predicate = (\Data.text).contains("Hello, World!")
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.contains('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .contains)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testArrayElementKeyPathContains() throws {
    let predicate = (\Data.relationships).all(\.text).contains("Hello, World!")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.all.text.contains('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be an array element key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)
    XCTAssertEqual(keyPath.type, .all)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .contains)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testContainsCaseInsensitive() throws {
    let predicate = (\Data.text).contains("Hello, World!", .caseInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.contains('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .contains)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testContainsDiacriticInsensitive() throws {
    let predicate = (\Data.text).contains("Hello, World!", .diacriticInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.contains('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .contains)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testContainsNormalized() throws {
    let predicate = (\Data.text).contains("Hello, World!", .normalized)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.contains('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .contains)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, "Hello, World!")
  }

  // MARK: - endsWith
  
  func testKeyPathEndsWith() throws {
    let predicate = (\Data.text).endsWith("Hello, World!")
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.endsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .endsWith)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testArrayElementKeyPathEndsWith() throws {
    let predicate = (\Data.relationships).any(\.text).endsWith("Hello, World!")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.any.text.endsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be an array element key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)
    XCTAssertEqual(keyPath.type, .any)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .endsWith)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testEndsWithCaseInsensitive() throws {
    let predicate = (\Data.text).endsWith("Hello, World!", .caseInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.endsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .endsWith)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testEndsWithDiacriticInsensitive() throws {
    let predicate = (\Data.text).endsWith("Hello, World!", .diacriticInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.endsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .endsWith)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testEndsWithNormalized() throws {
    let predicate = (\Data.text).endsWith("Hello, World!", .normalized)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.endsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .endsWith)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, "Hello, World!")
  }

  // MARK: - like
  
  func testKeyPathLike() throws {
    let predicate = (\Data.text).like("Hello, World!")
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.like('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .like)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testArrayElementKeyPathLike() throws {
    let predicate = (\Data.relationships).none(\.text).like("Hello, World!")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.none.text.like('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be an array element key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)
    XCTAssertEqual(keyPath.type, .none)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .like)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testLikeCaseInsensitive() throws {
    let predicate = (\Data.text).like("Hello, World!", .caseInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.like('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .like)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testLikeDiacriticInsensitive() throws {
    let predicate = (\Data.text).like("Hello, World!", .diacriticInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.like('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .like)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testLikeNormalized() throws {
    let predicate = (\Data.text).like("Hello, World!", .normalized)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .like)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, "Hello, World!")
  }
  
  // MARK: - matches
  
  func testKeyPathMatches() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]", options: [])
    let predicate = (\Data.text).matches(regexp)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.matches('[a-z]') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .matches)
    XCTAssertEqual(value, regexp.pattern)
  }

  func testArrayElementKeyPathMatches() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]", options: [])
    let predicate = (\Data.relationships).first(\.text).matches(regexp)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships[2].text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be an array element key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)
    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .matches)
    XCTAssertEqual(value, regexp.pattern)
  }
  
  func testMatchesCaseInsensitive() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]")
    let predicate = (\Data.text).matches(regexp, .caseInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .matches)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, "[a-z]")
  }

  func testMatchesDiacriticInsensitive() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]")
    let predicate = (\Data.text).matches(regexp, .diacriticInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .matches)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, "[a-z]")
  }

  func testMatchesNormalized() throws {
    let regexp = try NSRegularExpression(pattern: "[a-z]")
    let predicate = (\Data.text).matches(regexp, .normalized)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .matches)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, "[a-z]")
  }

  // MARK: - isEqualTo

  func testIsEqualToCaseInsensitive() throws {
    let predicate = (\Data.text).isEqualTo("Hello, World!", .caseInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testIsEqualToDiacriticInsensitive() throws {
    let predicate = (\Data.text).isEqualTo("Hello, World!", .diacriticInsensitive)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, "Hello, World!")
  }

  func testIsEqualToNormalized() throws {
    let predicate = (\Data.text).isEqualTo("Hello, World!", .normalized)
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.beginsWith('Hello, World!') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, "Hello, World!")
  }

  // MARK: - between

  func testKeyPathBetwen() throws {
    let predicate = (\Data.count).between(21...42)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count.between(21...42) should result in a comparison")
      return
    }
  
    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [Int])

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .between)
    XCTAssertEqual(value, [21, 42])
  }

  func testKeyPathBetweenOperator() throws {
    let predicate = \Data.count ~= 21...42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count ~= 21...42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [Int])

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .between)
    XCTAssertEqual(value, [21, 42])
  }

  func testArrayElementKeyPathBetwen() throws {
    let predicate = (\Data.relationships).first(\.count).between(21...42)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.count.between(21...42) should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [Int])
    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .between)
    XCTAssertEqual(value, [21, 42])
  }

  func testArrayElementKeyPathBetwenOperator() throws {
    let predicate = (\Data.relationships).first(\.count) ~= 21...42

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.count ~= 21...42 should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [Int])
    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .between)
    XCTAssertEqual(value, [21, 42])
  }

  // MARK: - in

  func testKeyPathIn() throws {
    let predicate: Predicate<Data> = (\Data.text).in("hello", "world", "welcome")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.in('hello', 'world', 'welcome') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(value, ["hello", "world", "welcome"])
  }
    
  func testKeyPathInArray() throws {
    let predicate: Predicate<Data> = (\Data.count).in([21, 42, 63])

    guard case let .comparison(comparison) = predicate else {
      XCTFail("count.in([21, 42, 63]) should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [Int])

    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(value, [21, 42, 63])
  }

  func testKeyPathInSet() throws {
    let predicate: Predicate<Data> = (\Data.count).in(Set([21, 42, 63]))
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("count.in(Set([21, 42, 63])) should result in a comparison")
      return
    }
    
    guard let keyPath = comparison.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }
    
    let value = try XCTUnwrap(comparison.value as? [Int])
    
    XCTAssertEqual(keyPath, \Data.count)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertTrue(value.contains(21), "searched item '\(21)' is missing in comparison.value")
    XCTAssertTrue(value.contains(42), "searched item '\(42)' is missing in comparison.value")
    XCTAssertTrue(value.contains(63), "searched item '\(63)' is missing in comparison.value")
    XCTAssertEqual(value.count, 3, "IN expression had \(3) items, found \(value.count)")
  }
  
  func testKeyPathInCaseInsensitive() throws {
    let predicate: Predicate<Data> = (\Data.text).in(["hello", "world", "welcome"], .caseInsensitive)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.in('hello', 'world', 'welcome') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, ["hello", "world", "welcome"])
  }

  func testKeyPathInDiacriticInsensitive() throws {
    let predicate: Predicate<Data> = (\Data.text).in(["hello", "world", "welcome"], .diacriticInsensitive)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.in('hello', 'world', 'welcome') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, ["hello", "world", "welcome"])
  }

  func testKeyPathInNormalized() throws {
    let predicate: Predicate<Data> = (\Data.text).in(["hello", "world", "welcome"], .normalized)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("text.in('hello', 'world', 'welcome') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])

    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, ["hello", "world", "welcome"])
  }

  func testArrayElementKeyPathIn() throws {
    let predicate: Predicate<Data> = (\Data.relationships).last(\.text).in("hello", "world")

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.text.in('hello', 'world') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(value, ["hello", "world"])
  }

  func testArrayElementKeyPathInCaseInsensitive() throws {
    let predicate: Predicate<Data> = (\Data.relationships).last(\.text).in(["hello", "world"], .caseInsensitive)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.text.in('hello', 'world') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(comparison.options, .caseInsensitive)
    XCTAssertEqual(value, ["hello", "world"])
  }

  func testArrayElementKeyPathInDiacriticInsensitive() throws {
    let predicate: Predicate<Data> = (\Data.relationships).last(\.text).in(["hello", "world"], .diacriticInsensitive)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.text.in('hello', 'world') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(comparison.options, .diacriticInsensitive)
    XCTAssertEqual(value, ["hello", "world"])
  }

  func testArrayElementKeyPathInNormalized() throws {
    let predicate: Predicate<Data> = (\Data.relationships).last(\.text).in(["hello", "world"], .normalized)

    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.text.in('hello', 'world') should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? [String])
    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .in)
    XCTAssertEqual(comparison.options, .normalized)
    XCTAssertEqual(value, ["hello", "world"])
  }

  // MARK: - any, all, none

  func testSelfKeyPathAny() throws {
    let predicate = (\Data.stocks).any >= 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.any >= 35.0 should result in an ALL aggregate comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Double]>, Double>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath.array, \Data.stocks)
    XCTAssertEqual(keyPath.elementKeyPath, \Double.self)
    XCTAssertEqual(keyPath.type, .any)
    XCTAssertEqual(comparison.operator, .greaterThanOrEqual)
    XCTAssertEqual(value, 35.0)
  }

  func testKeyPathAny() throws {
    let predicate: Predicate<Data> = (\Data.relationships).any(\.count) == 42
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.any.count == 42 should result in an ANY aggregate comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self) else {
      XCTFail("the left side of the comparison should be an array key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 42)
  }

  func testArrayElementKeyPathAny() throws {
    let predicate = (\Data.relationships).first(\.relationships).any(\.count) < 42
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.first.relationships.any.count == 42 should result in an ANY aggregate comparison")
      return
    }

    guard
      let keyPath = comparison
          .expression.as(
            ArrayElementKeyPath<
              ArrayElementKeyPath<
                KeyPath<Data, [Relationship]>,
                [NestedRelationship]
              >,
              Int
            >.self
          )
      else {
      XCTFail("the left side of the comparison should be an array key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .any)
    XCTAssertEqual(keyPath.elementKeyPath, \NestedRelationship.count)
    XCTAssertEqual(keyPath.array.type, .first)
    XCTAssertEqual(keyPath.array.array, \Data.relationships)
    XCTAssertEqual(keyPath.array.elementKeyPath, \Relationship.relationships)
    XCTAssertEqual(comparison.operator, .lessThan)
    XCTAssertEqual(value, 42)
  }

  func testSelfKeyPathAll() throws {
    let predicate: Predicate<Data> = (\Data.stocks).all < 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.all < 35.0 should result in an ALL aggregate comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Double]>, Double>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath.array, \Data.stocks)
    XCTAssertEqual(keyPath.elementKeyPath, \Double.self)
    XCTAssertEqual(keyPath.type, .all)
    XCTAssertEqual(comparison.operator, .lessThan)
    XCTAssertEqual(value, 35.0)
  }
  
  func testKeyPathAll() throws {
    let predicate: Predicate<Data> = (\Data.relationships).all(\.count) == 42
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.all.count == 42 should result in an ALL aggregate comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 42)
  }

  func testArrayElementKeyPathAll() throws {
    let predicate = (\Data.relationships).last(\.relationships).all(\.count) >= 42
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.last.relationships.all.count >= 42 should result in an ALL aggregate comparison")
      return
    }

    guard
      let keyPath = comparison
          .expression.as(
            ArrayElementKeyPath<
              ArrayElementKeyPath<
                KeyPath<Data, [Relationship]>,
                [NestedRelationship]
              >,
              Int
            >.self
          )
      else {
      XCTFail("the left side of the comparison should be an array key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .all)
    XCTAssertEqual(keyPath.elementKeyPath, \NestedRelationship.count)
    XCTAssertEqual(keyPath.array.type, .last)
    XCTAssertEqual(keyPath.array.array, \Data.relationships)
    XCTAssertEqual(keyPath.array.elementKeyPath, \Relationship.relationships)
    XCTAssertEqual(comparison.operator, .greaterThanOrEqual)
    XCTAssertEqual(value, 42)
  }
  
  func testSelfKeyPathNone() throws {
    let predicate: Predicate<Data> = (\Data.stocks).none == 35.0

    guard case let .comparison(comparison) = predicate else {
      XCTFail("stocks.any >= 35.0 should result in an ALL aggregate comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Double]>, Double>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Double)
    XCTAssertEqual(keyPath.array, \Data.stocks)
    XCTAssertEqual(keyPath.elementKeyPath, \Double.self)
    XCTAssertEqual(keyPath.type, .none)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 35.0)
  }

  func testKeyPathNone() throws {
    let predicate: Predicate<Data> = (\Data.relationships).none(\.count) > 42
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships.none.count > 42 should result in a NOT ANY aggregate comparison")
      return
    }

    guard let keyPath = comparison.expression.as(ArrayElementKeyPath<KeyPath<Data, [Relationship]>, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)

    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.count)
    XCTAssertEqual(comparison.operator, .greaterThan)
    XCTAssertEqual(value, 42)
  }

  func testArrayElementKeyPathNone() throws {
    let predicate = (\Data.relationships).at(index: 2, \.relationships).none(\.count) == 42
    
    guard case let .comparison(comparison) = predicate else {
      XCTFail("relationships[2].relationships.none.count == 42 should result in an ANY aggregate comparison")
      return
    }

    guard
      let keyPath = comparison
          .expression.as(
            ArrayElementKeyPath<
              ArrayElementKeyPath<
                KeyPath<Data, [Relationship]>,
                [NestedRelationship]
              >,
              Int
            >.self
          )
      else {
      XCTFail("the left side of the comparison should be an array key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? Int)
    XCTAssertEqual(keyPath.type, .none)
    XCTAssertEqual(keyPath.elementKeyPath, \NestedRelationship.count)
    XCTAssertEqual(keyPath.array.type, .index(2))
    XCTAssertEqual(keyPath.array.array, \Data.relationships)
    XCTAssertEqual(keyPath.array.elementKeyPath, \Relationship.relationships)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, 42)
  }

  // MARK: - array.at(index:)

  func testKeyPathIndexAtReturnsArrayFunction() throws {
    let function = (\Data.tags).at(index: 2)

    guard case let .index(keyPath, index) = function else {
      XCTFail("tags.at(index: 2) should result in the index: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(index, 2)
  }

  func testKeyPathIndexAtReturnsArrayFunction2() throws {
    let function = (\Data.tags).at(index: 42)

    guard case let .index(keyPath, index) = function else {
      XCTFail("tags.at(index: 42) should result in the index: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.tags)
    XCTAssertEqual(index, 42)
  }

  func testArrayElementKeyPathIndexAtReturnsArrayElement() throws {
    let index = (\Data.relationships).at(index: 2, \.relationships).at(index: 0)

    guard case let .index(keyPath, indexValue) = index else {
      XCTFail("relationships[2].relationships[0] should result in the 'index' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .index(2))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.relationships)
    XCTAssertEqual(indexValue, 0)
  }

  // MARK: - array.first

  func testKeyPathFirstReturnsArrayFunction() throws {
    let function = (\Data.tags).first

    guard case let .first(keyPath) = function else {
      XCTFail("tags.first should result in the first: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.tags)
  }

  func testArrayElementKeyPathFirstReturnsArrayElement() throws {
    let element = (\Data.relationships).at(index: 5, \.relationships).first

    guard case let .first(keyPath) = element else {
      XCTFail("relationships[5].relationships.first should result in the 'first' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .index(5))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.relationships)
  }

  // MARK: - array.last

  func testKeyPathLastReturnsArrayFunction() throws {
    let function = (\Data.tags).last

    guard case let .last(keyPath) = function else {
      XCTFail("tags.last should result in the last: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.tags)
  }

  func testArrayElementKeyPathLastReturnsArrayElement() throws {
    let function = (\Data.relationships).at(index: 2, \.relationships).last

    guard case let .last(keyPath) = function else {
      XCTFail("relationships[2].relationships.last should result in the 'last' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .index(2))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.relationships)
  }
  
  // MARK: - array.size

  func testKeyPathSizeReturnsArrayFunction() throws {
    let function = (\Data.tags).size

    guard case let .size(keyPath) = function else {
      XCTFail("tags.size should result in the size: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.tags)
  }

  func testArrayElementKeyPathSizeReturnsArrayFunction() throws {
    let function = (\Data.relationships).at(index: 5, \.relationships).size

    guard case let .size(keyPath) = function else {
      XCTFail("relationships[5].relationships.first should result in the 'size' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .index(5))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.relationships)
  }

  // MARK: - array.count

  func testKeyPathCountReturnsFunction() throws {
    let function = (\Data.tags).count

    guard case let .count(keyPath) = function else {
      XCTFail("tags.count should result in the count: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.tags)
  }

  func testArrayElementKeyPathCountReturnsFunction() throws {
    let function = (\Data.relationships).at(index: 5, \.relationships).count

    guard case let .count(keyPath) = function else {
      XCTFail("relationships[5].relationships.count should result in the 'count' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .index(5))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.relationships)
  }

  func testQueryCountReturnsFunction() throws {
    let function = all(\Data.relationships, where: \Relationship.text == "Hello, World!").count

    guard case let .count(query) = function else {
      XCTFail("all.relationships(where: text == 'Hello, World!').count should result in the 'count` function")
      return
    }

    guard case let .comparison(comparison) = query.predicate else {
      XCTFail("the predicate of the query should be a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Relationship, String>.self) else {
      XCTFail("the left side of the comparison should be a key path")
      return
    }

    XCTAssertEqual(query.key, \Data.relationships)
    XCTAssertEqual(keyPath, \Relationship.text)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(comparison.value as? String, "Hello, World!")
  }

  // MARK: - average
  
  func testKeyPathAverageReturnsFunction() throws {
    let function = (\Data.stocks).average

    guard case let .average(keyPath) = function else {
      XCTFail("stocks.average should result in the average: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.stocks)
  }

  func testArrayElementKeyPathAverageReturnsFunction() throws {
    let function = (\Data.relationships).at(index: 5, \.stocks).average

    guard case let .average(keyPath) = function else {
      XCTFail("relationships[5].stocks.average should result in the 'average' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .index(5))
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.stocks)
  }

  // MARK: - mode
  
  func testKeyPathModeReturnsFunction() throws {
    let function = (\Data.stocks).mode

    guard case let .mode(keyPath) = function else {
      XCTFail("stocks.mode should result in the 'mode' function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.stocks)
  }

  func testArrayElementKeyPathModeReturnsFunction() throws {
    let function = (\Data.relationships).first(\.stocks).mode

    guard case let .mode(keyPath) = function else {
      XCTFail("relationships.first.stocks.mode should result in the 'mode' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.stocks)
  }
  
  // MARK: - min
  
  func testKeyPathMinReturnsFunction() throws {
    let function = (\Data.stocks).min

    guard case let .min(keyPath) = function else {
      XCTFail("stocks.min should result in the 'min' function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.stocks)
  }

  func testArrayElementKeyPathMinReturnsFunction() throws {
    let function = (\Data.relationships).last(\.stocks).min

    guard case let .min(keyPath) = function else {
      XCTFail("relationships.last.stocks.min should result in the 'min' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.stocks)
  }

  // MARK: - max
  
  func testKeyPathMaxReturnsFunction() throws {
    let function = (\Data.stocks).max

    guard case let .max(keyPath) = function else {
      XCTFail("stocks.max should result in the max: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.stocks)
  }

  func testArrayElementKeyPathMaxReturnsFunction() throws {
    let function = (\Data.relationships).last(\.stocks).max

    guard case let .max(keyPath) = function else {
      XCTFail("relationships.last.stocks.min should result in the 'max' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .last)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.stocks)
  }
  
  // MARK: - sum
  
  func testKeyPathSumReturnsFunction() throws {
    let function = (\Data.stocks).sum

    guard case let .sum(keyPath) = function else {
      XCTFail("stocks.sum should result in the sum: function expression")
      return
    }

    XCTAssertEqual(keyPath, \Data.stocks)
  }

  func testArrayElementKeyPathSumReturnsFunction() throws {
    let function = (\Data.relationships).first(\.stocks).sum

    guard case let .sum(keyPath) = function else {
      XCTFail("relationships.first.stocks.max should result in the 'max' function expression")
      return
    }

    XCTAssertEqual(keyPath.type, .first)
    XCTAssertEqual(keyPath.array, \Data.relationships)
    XCTAssertEqual(keyPath.elementKeyPath, \Relationship.stocks)
  }

  // MARK: && (and), || (or), ! (not)

  func testAnd() throws {
    let predicate = \Data.text == "Hello, World!" && \Data.count <= 42

    guard case let .and(lhs, rhs) = predicate else {
      XCTFail("text == 'Hello, World!' && count <= 42 should result in an AND predicate")
      return
    }

    guard case let .comparison(left) = lhs else {
      XCTFail("text == 'Hello, World!' should result in a comparison")
      return
    }

    guard let leftKeyPath = left.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let leftValue = try XCTUnwrap(left.value as? String)
    XCTAssertEqual(leftKeyPath, \Data.text)
    XCTAssertEqual(left.operator, .equal)
    XCTAssertEqual(leftValue, "Hello, World!")
    
    guard case let .comparison(right) = rhs else {
      XCTFail("count <= 42 should result in a comparison")
      return
    }

    guard let rightKeyPath = right.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let rightValue = try XCTUnwrap(right.value as? Int)
    XCTAssertEqual(rightKeyPath, \Data.count)
    XCTAssertEqual(right.operator, .lessThanOrEqual)
    XCTAssertEqual(rightValue, 42)
  }

  func testOr() throws {
    let predicate = \Data.text == "Hello, World!" || \Data.count <= 42

    guard case let .or(lhs, rhs) = predicate else {
      XCTFail("text == 'Hello, World!' || count <= 42 should result in an OR predicate")
      return
    }

    guard case let .comparison(left) = lhs else {
      XCTFail("text == 'Hello, World!' should result in a comparison")
      return
    }

    guard let leftKeyPath = left.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let leftValue = try XCTUnwrap(left.value as? String)
    XCTAssertEqual(leftKeyPath, \Data.text)
    XCTAssertEqual(left.operator, .equal)
    XCTAssertEqual(leftValue, "Hello, World!")
    
    guard case let .comparison(right) = rhs else {
      XCTFail("count <= 42 should result in a comparison")
      return
    }

    guard let rightKeyPath = right.expression.as(KeyPath<Data, Int>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let rightValue = try XCTUnwrap(right.value as? Int)
    XCTAssertEqual(rightKeyPath, \Data.count)
    XCTAssertEqual(right.operator, .lessThanOrEqual)
    XCTAssertEqual(rightValue, 42)
  }

  func testNot() throws {
    let predicate = !(\Data.text == "Hello, World!")

    guard case let .not(rhs) = predicate else {
      XCTFail("!(text == 'Hello, World!') in a NOT predicate")
      return
    }

    guard case let .comparison(comparison) = rhs else {
      XCTFail("text == 'Hello, World!' should result in a comparison")
      return
    }

    guard let keyPath = comparison.expression.as(KeyPath<Data, String>.self) else {
      XCTFail("the left side of the comparison should be a key path expression")
      return
    }

    let value = try XCTUnwrap(comparison.value as? String)
    XCTAssertEqual(keyPath, \Data.text)
    XCTAssertEqual(comparison.operator, .equal)
    XCTAssertEqual(value, "Hello, World!")
  }

  // MARK: - Boolean literals

  func testTrue() throws {
    let predicate: Predicate<Data> = true

    guard case let .boolean(value) = predicate else {
      XCTFail("true should evaluate to a boolean predicate")
      return
    }

    XCTAssertTrue(value)
  }

  func testFalse() throws {
    let predicate: Predicate<Data> = false

    guard case let .boolean(value) = predicate else {
      XCTFail("false should evaluate to a boolean predicate")
      return
    }

    XCTAssertFalse(value)
  }
}

// MARK: -

private struct Data {
  let text: String
  let count: Int
  let tags: [String]
  let stocks: [Double]
  let relationships: [Relationship]
  let creationDate: Date
  let optionalRelationship: Relationship?
  let optionalRelationships: [Relationship]?
  let identifiable: IdentifiableData?
}

private struct Relationship {
  let text: String
  let count: Int
  let stocks: [Double]
  let relationships: [NestedRelationship]
}

private struct NestedRelationship {
  let text: String
  let count: Int
}

//
//  Primitive.swift
//  PredicateKit
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

// MARK: - Primitive

public protocol Primitive {
  static var type: Type { get }
  var predicateValue: Any? { get }
}

public indirect enum Type: Equatable {
  case bool
  case int
  case int8
  case int16
  case int32
  case int64
  case uint
  case uint8
  case uint16
  case uint32
  case uint64
  case double
  case float
  case string
  case date
  case url
  case uuid
  case data
  case wrapped(Type)
  case array(Type)
  case `nil`
}

extension Primitive {
  public var predicateValue: Any? { self }
}

extension Bool: Primitive {
  public static var type: Type { .bool }
}

extension Int: Primitive {
  public static var type: Type { .int }
}

extension Int8: Primitive {
  public static var type: Type { .int8 }
}

extension Int16: Primitive {
  public static var type: Type { .int16 }
}

extension Int32: Primitive {
  public static var type: Type { .int32 }
}

extension Int64: Primitive {
  public static var type: Type { .int64 }
}

extension UInt: Primitive {
  public static var type: Type { .uint }
}

extension UInt8: Primitive {
  public static var type: Type { .uint8 }
}

extension UInt16: Primitive {
  public static var type: Type { .uint16 }
}

extension UInt32: Primitive {
  public static var type: Type { .uint32 }
}

extension UInt64: Primitive {
  public static var type: Type { .uint64 }
}

extension Double: Primitive {
  public static var type: Type { .double }
}

extension Float: Primitive {
  public static var type: Type { .float }
}

extension String: Primitive {
  public static var type: Type { .string }
}

extension Date: Primitive {
  public static var type: Type { .date }
}

// TODO: Potentially remove this in the next major version. RawRepresentables (with primitive
// raw values) can already be used in predicates without explicitly conforming to Primitive.
extension Primitive where Self: RawRepresentable, RawValue: Primitive {
  public static var type: Type { RawValue.type }

  public var predicateValue: Any? { rawValue }
}

extension Array: Primitive where Element: Primitive {
  public static var type: Type { .array(Element.type) }
}

extension URL: Primitive {
  public static var type: Type { .url }
}

extension UUID: Primitive {
  public static var type: Type { .uuid }
}

extension Data: Primitive {
  public static var type: Type { .data }
}

extension Optional: Primitive where Wrapped: Primitive {
  public static var type: Type { Wrapped.type }
}

public struct Nil: Primitive, ExpressibleByNilLiteral {
  public static var type: Type { .nil }

  public var predicateValue: Any? { NSNull() }

  public init(nilLiteral: ()) {
  }
}

// MARK: - Optional

public protocol OptionalType {
  associatedtype Wrapped
}

extension Optional: OptionalType {
}

extension Optional: Comparable where Wrapped: Comparable {
  public static func < (lhs: Self, rhs: Self) -> Bool {
    switch (lhs, rhs) {
    case let (.some(lhs), .some(rhs)):
      return lhs < rhs
    default:
      return false
    }
  }
}

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
extension Optional: Identifiable where Wrapped: Identifiable {
  public var id: Wrapped.ID? {
    self?.id
  }
}

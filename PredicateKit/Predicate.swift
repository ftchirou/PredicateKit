//
//  Predicate.swift
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

// Tag: - Predicate
///
/// A type-safe set of conditions used to filter a list of objects of type `Root`.
///
/// Predicates are expressed using a combination of comparison operators, logical operators, and functions.
///
/// # Comparisons
///
/// ## Basic comparisons
///
/// Comparisons can be expressed using the basic comparison operators `<`, `<=`, `==`, `>=`, and `>` where the left hand side of
/// the operator is a [KeyPath](https://developer.apple.com/documentation/swift/keypath) from `T`; and the right hand side
/// of the operator is a value whose type matches the value type of the key path on the left hand side.
///
/// ###### Example
///
///     struct Note {
///       let text: String
///       let creationDate: Date
///       let numberOfViews: Int
///       let tags: [String]
///     }
///
///     // Matches all notes where the text is equal to "Hello, World!".
///     let predicate = \Note.text == "Hello, World!"
///
///     // Matches all notes created before the current date.
///     let predicate = \Note.creationDate < Date()
///
///     // Matches all notes where the number of views is at least 120.
///     let predicate = \Note.numberOfViews >= 120
///
/// ## String comparisons
///
/// If the property to compare is of type `String`, comparisons can be additionally expressed with special functions such as `beginsWith`,
/// `contains`, or `endsWith`.
///
///     // Matches all notes where the text begins with the string "Hello".
///     let predicate = (\Note.text).beginsWith("Hello")
///
///     // Matches all notes where the text contains the string "Hello".
///     let predicate = (\Note.text).contains("Hello")
///
///     // Matches all notes where the text matches the specified regular expression.
///     let predicate = (\Note.text).matches(NSRegularExpression(...))
///
/// Any of the following functions can be used in a string comparison predicate.
///
/// - `beginsWith(_: String)`
/// - `contains(_: String)`
/// - `endsWith(_: String)`
/// - `like(_: String)`
/// - `matches(_: NSRegularExpression)`
///
/// ## Membership checks
///
/// You can use the `between` or `in` functions to determine whether a property's value is within a specified set of values of the same type.
///
///     // Matches all notes where the number of views is between 100 and 200.
///     let predicate = (\Note.numberOfViews).between(100...200)
///
///     // Matches all notes where the text is one of the elements in the specified list.
///     let predicate = (\Note.text).in("a", "b", "c", "d")
///
/// # Compound Predicates
///
/// Compound predicates are predicates that logically combine one, two or more predicates together.
///
/// ## AND Predicates
///
/// AND predicates are expressed with the `&&` operator where the operands are predicates. An AND predicate
/// matches objects where both its operands match.
///
///     // Matches all notes where the text begins with 'hello' and the number of views is at least 120.
///     let predicate = (\Note.text).beginsWith("hello") && \Note.numberOfViews >= 120
///
/// ## OR Predicates
///
/// OR predicates are expressed with the `||` operator where the operands are predicates. An OR predicate matches
/// objects where at least one of its operand matches.
///
///     // Matches all notes with the text containing 'hello' or created before the current date.
///     let predicate = (\Note.text).contains("hello") || \Note.creationDate < Date()
///
/// ## NOT Predicates
///
/// NOT predicates are expressed with the unary `!` operator with a predicate operand. A NOT predicate matches all objects
/// where its operand does not match.
///
///     // Matches all notes where the text is not equal to 'Hello, World!'
///     let predicate = !(\Note.text == "Hello, World!")
///
/// # Array Operations
///
/// You can perform operations on properties of type `Array` and use the result in a predicate.
///
/// ## Select an element in an array
///
/// ###### first
///
///     // Matches all notes where the first tag is 'To Do'..
///     let predicate = (\Note.tags).first == "To Do"
///
/// ###### last
///
///     // Matches all notes where the last tag is 'To Do'..
///     let predicate = (\Note.tags).last == "To Do"
///
/// ###### at(index: Int)
///
///     // Matches all notes where the third tag contains 'To Do'.
///     let predicate = \(Note.tags).at(index: 2).contains("To Do")
///
/// ## Count the number of elements in an array
///
/// ###### count
///
///     // Matches all notes where the number of elements in the `tags` array is less than 5.
///     let predicate = \(Note.tags).count < 5
///
/// ## Combine the elements in an array
///
/// If the elements of an array are numbers, you can combine or reduce them into a single number and use the result in a predicate.
///
///     struct Account {
///       let purchases: [Double]
///     }
///
/// ###### sum
///
///     // Matches all accounts where the sum of the purchases is less than 2000.
///     let predicate = (\Account.purchases).sum < 2000
///
/// ###### average
///
///     // Matches all accounts where the average purchase is 120.0
///     let predicate = (\Account.purchases).average == 120.0
///
/// ###### min
///
///     // Matches all accounts where the minimum purchase is 98.5.
///     let predicate = (\Account.purchases).min == 98.5
///
/// ###### max
///
///     // Matches all accounts where the maximum purchase is at least 110.5.
///     let predicate = (\Account.purchases).max >= 110.5
///
/// ## Aggregate comparisons
///
/// You can also express predicates matching all, any, or none of the elements of an array.
///
/// ###### all
///
///      // Matches all accounts where every purchase is at least 95.0
///      let predicate = (\Account.purchases).all >= 95.0
///
/// ###### any
///
///      // Matches all accounts having at least one purchase of 20.0
///      let predicate = (\Account.purchases).any == 20.0
///
/// ###### none
///
///     // Matches all accounts where no purchase is less than 50.
///     let _: Predicate: <Account> = (\Account.purchases).none <= 50
///
/// # Predicates on types with one-to-one relationships
///
/// If a type has a one-to-one relationship to another one, you can target any property of the relationship simply by
/// using the appropriate key-path.
///
/// ###### Example
///
///     struct User {
///       let name: String
///       let billingInfo: BillingInfo
///     }
///
///     struct BillingInfo {
///       let accountType: String
///       let purchases: [Double]
///     }
///
///     // Matches all users with the billing account type 'Pro'
///     let _: Predicate<User> = \User.billingInfo.accountType == "Pro"
///
///     // Matches all users with an average purchase of 120
///     let _: Predicate<User> = (\User.billingInfo.purchases).average == 120.0
///
/// # Predicates on types with one-to-many relationships
///
/// You can run aggregate operations on a set of relationships using the `all(_:)`, `any(_:)`, or `none(_:)` functions.
///
/// ###### Example
///
///     struct Account {
///       let name: String
///       let profiles: Set<Profile>
///     }
///
///     struct Profile {
///       let name: String
///       let creationDate: String
///     }
///
///     // Matches all accounts where all the profiles have the creation date equal to the specified one.
///     let predicate = (\Account.profile).all(\.creationDate) == date
///
///     // Matches all accounts where any of the associated profiles has a name containing 'John'.
///     let predicate = (\Account.profiles).any(\.name).contains("John"))
///
///     // Matches all accounts where no profile has the name 'John Doe'
///     let predicate = (\Account.profiles).none(\.name) == "John Doe"
///
/// # Sub-predicates
///
/// When your object has a one-to-many relationships, you can create a sub-predicate that filters the "many" relationships and use the
/// resuult of the sub-predicate in a more complex predicate. Sub-predicates are created using the global `all(_:where:)` function. The first
/// parameter is the key-path of the collection to filter and the second parameter is a predicate that filters the collection.
///
/// `all(_:where:)` evaluates to an array; that means you can perform any valid operation on its result such as `size`, `first`, etc.
///
/// ###### Example
///
///     // Matches all the accounts where the name contains 'Account' and where the number of profiles whose
///     // name contains 'Doe' is exactly 2.
///     let predicate = (\Account.name).contains("Account") && all(\.profiles, where: (\Profile.name).contains("Doe")).size == 2)
///
///
public indirect enum Predicate<Root> {
  case comparison(Comparison)
  case boolean(Bool)
  case and(Predicate<Root>, Predicate<Root>)
  case or(Predicate<Root>, Predicate<Root>)
  case not(Predicate<Root>)
}

public struct Comparison {
  let expression: AnyExpression
  let `operator`: ComparisonOperator
  let options: ComparisonOptions
  let value: Primitive
}

public protocol Expression {
  associatedtype Root
  associatedtype Value

  var comparisonModifier: ComparisonModifier { get }
}

extension KeyPath: Expression {
}

public enum Function<Input: Expression, Output>: Expression where Input.Value: AnyArrayOrSet {
  public typealias Root = Input.Root
  public typealias Value = Output

  case average(Input)
  case count(Input)
  case sum(Input)
  case min(Input)
  case max(Input)
  case mode(Input)
  case size(Input)
}

public enum Index<Array: Expression>: Expression where Array.Value: AnyArray {
  public typealias Root = Array.Root
  public typealias Value = Array.Value.ArrayElement

  case index(Array, Int)
  case first(Array)
  case last(Array)
}

public struct Query<Root, Subject: AnyArrayOrSet>: Expression {
  public typealias Value = Subject

  let key: AnyKeyPath
  let predicate: Predicate<Subject.Element>
}

public struct ArrayElementKeyPath<Array, Value>: Expression where Array: Expression, Array.Value: AnyArrayOrSet {
  public typealias Root = Array.Root
  public typealias Element = Array.Value.Element

  let type: ArrayElementKeyPathType
  let array: Array
  let elementKeyPath: AnyKeyPath
}

public struct ObjectIdentifier<Object: Expression, Identifier: Primitive>: Expression {
  public typealias Root = Object
  public typealias Value = Identifier

  let root: Object
}

enum ComparisonOperator {
  case lessThan
  case lessThanOrEqual
  case equal
  case notEqual
  case greaterThanOrEqual
  case greaterThan
  case between
  case beginsWith
  case contains
  case endsWith
  case like
  case matches
  case `in`
}

public enum ComparisonModifier {
  case direct
  case all
  case any
  case none
}

public struct ComparisonOptions: OptionSet {
  public let rawValue: Int

  public static let caseInsensitive = ComparisonOptions(rawValue: 1 << 0)
  public static let diacriticInsensitive = ComparisonOptions(rawValue: 1 << 1)
  public static let normalized = ComparisonOptions(rawValue: 1 << 2)
  public static let none = ComparisonOptions(rawValue: 1 << 3)

  public init(rawValue: Int) {
    self.rawValue = rawValue
  }
}

enum ArrayElementKeyPathType: Equatable {
  case index(Int)
  case first
  case last
  case all
  case any
  case none
}

// MARK: - Basic Comparisons

public func < <E: Expression, T: Comparable & Primitive> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T {
  .comparison(.init(lhs, .lessThan, rhs))
}

public func < <E: Expression, T: RawRepresentable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.RawValue: Comparable & Primitive {
  .comparison(.init(lhs, .lessThan, rhs.rawValue))
}

public func <= <E: Expression, T: Comparable & Primitive> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T {
  .comparison(.init(lhs, .lessThanOrEqual, rhs))
}

public func <= <E: Expression, T: RawRepresentable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.RawValue: Comparable & Primitive {
  .comparison(.init(lhs, .lessThanOrEqual, rhs.rawValue))
}

public func == <E: Expression, T: Equatable & Primitive> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T {
  .comparison(.init(lhs, .equal, rhs))
}

public func == <E: Expression, T: RawRepresentable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.RawValue: Equatable & Primitive {
  .comparison(.init(lhs, .equal, rhs.rawValue))
}

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func == <E: Expression, T: Identifiable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.ID: Primitive {
  .comparison(.init(ObjectIdentifier<E, T.ID>(root: lhs), .equal, rhs.id))
}

@_disfavoredOverload
public func == <E: Expression> (lhs: E, rhs: Nil) -> Predicate<E.Root> where E.Value: OptionalType {
  .comparison(.init(lhs, .equal, rhs))
}

public func != <E: Expression, T: Equatable & Primitive> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T {
  .comparison(.init(lhs, .notEqual, rhs))
}

public func != <E: Expression, T: RawRepresentable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.RawValue: Equatable & Primitive {
  .comparison(.init(lhs, .notEqual, rhs.rawValue))
}

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
public func != <E: Expression, T: Identifiable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.ID: Primitive {
  .comparison(.init(ObjectIdentifier<E, T.ID>(root: lhs), .notEqual, rhs.id))
}

@_disfavoredOverload
public func != <E: Expression> (lhs: E, rhs: Nil) -> Predicate<E.Root> where E.Value: OptionalType {
  .comparison(.init(lhs, .notEqual, rhs))
}

public func >= <E: Expression, T: Comparable & Primitive> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T {
  .comparison(.init(lhs, .greaterThanOrEqual, rhs))
}

public func >= <E: Expression, T: RawRepresentable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.RawValue: Comparable & Primitive {
  .comparison(.init(lhs, .greaterThanOrEqual, rhs.rawValue))
}

public func > <E: Expression, T: Comparable & Primitive> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T {
  .comparison(.init(lhs, .greaterThan, rhs))
}

public func > <E: Expression, T: RawRepresentable> (lhs: E, rhs: T) -> Predicate<E.Root> where E.Value == T, T.RawValue: Comparable & Primitive {
  .comparison(.init(lhs, .greaterThan, rhs.rawValue))
}

// MARK: - Compound Predicates

public func && <T> (lhs: Predicate<T>, rhs: Predicate<T>) -> Predicate<T> {
  .and(lhs, rhs)
}

public func || <T> (lhs: Predicate<T>, rhs: Predicate<T>) -> Predicate<T> {
  .or(lhs, rhs)
}

public prefix func ! <T> (predicate: Predicate<T>) -> Predicate<T> {
  .not(predicate)
}

// MARK: - String Comparisons

extension Expression where Value: StringValue {
  public func isEqualTo(_ string: String, _ options: ComparisonOptions) -> Predicate<Root> {
    .comparison(.init(self, .equal, string, options))
  }

  public func beginsWith(_ string: String, _ options: ComparisonOptions = .caseInsensitive) -> Predicate<Root> {
    .comparison(.init(self, .beginsWith, string, options))
  }

  public func contains(_ string: String, _ options: ComparisonOptions = .caseInsensitive) -> Predicate<Root> {
    .comparison(.init(self, .contains, string, options))
  }

  public func endsWith(_ string: String, _ options: ComparisonOptions = .caseInsensitive) -> Predicate<Root> {
    .comparison(.init(self, .endsWith, string, options))
  }

  public func like(_ string: String, _ options: ComparisonOptions = .caseInsensitive) -> Predicate<Root> {
    .comparison(.init(self, .like, string, options))
  }

  public func matches(_ regex: NSRegularExpression, _ options: ComparisonOptions = .caseInsensitive) -> Predicate<Root> {
    .comparison(.init(self, .matches, regex.pattern, options))
  }
}

// MARK: - Range Comparison

extension Expression where Value: Comparable & Primitive {
  public func between(_ range: ClosedRange<Value>) -> Predicate<Root> {
    .comparison(.init(self, .between, [range.lowerBound, range.upperBound]))
  }
}

public func ~= <E: Expression, T: Comparable & Primitive> (
  lhs: E,
  rhs: ClosedRange<T>
) -> Predicate<E.Root> where E.Value == T {
  lhs.between(rhs)
}

// MARK: - Aggregate Operations

extension Expression where Value: AnyArrayOrSet {
  public var all: ArrayElementKeyPath<Self, Value.Element> {
    all(\Value.Element.self)
  }

  public var any: ArrayElementKeyPath<Self, Value.Element> {
    any(\Value.Element.self)
  }

  public var none: ArrayElementKeyPath<Self, Value.Element> {
    none(\Value.Element.self)
  }

  public func all<T>(_ keyPath: KeyPath<Value.Element, T>) -> ArrayElementKeyPath<Self, T> {
    .init(.all, self, keyPath)
  }

  public func any<T>(_ keyPath: KeyPath<Value.Element, T>) -> ArrayElementKeyPath<Self, T> {
    .init(.any, self, keyPath)
  }

  public func none<T>(_ keyPath: KeyPath<Value.Element, T>) -> ArrayElementKeyPath<Self, T> {
    .init(.none, self, keyPath)
  }
}

extension Expression where Value: Primitive {
  public func `in`(_ list: Value...) -> Predicate<Root> {
    .comparison(.init(self, .in, list))
  }

  public func `in`(_ list: [Value]) -> Predicate<Root> {
    .comparison(.init(self, .in, list))
  }
    
  public func `in`(_ set: Set<Value>) -> Predicate<Root> where Value: Hashable {
    .comparison(.init(self, .in, Array(set)))
  }
}

extension Expression where Value: StringValue & Primitive {
  public func `in`(_ list: [Value], _ options: ComparisonOptions = .caseInsensitive) -> Predicate<Root> {
    .comparison(.init(self, .in, list, options))
  }
}

// MARK: - Array Operations

extension Expression where Value: AnyArray {
  public func at(index: Int) -> Index<Self> {
    .index(self, index)
  }

  public var first: Index<Self> {
    .first(self)
  }
  
  public var last: Index<Self> {
    .last(self)
  }

  public func at<T>(index: Int, _ keyPath: KeyPath<Value.ArrayElement, T>) -> ArrayElementKeyPath<Self, T> {
    .init(.index(index), self, keyPath)
  }

  public func first<T>(_ keyPath: KeyPath<Value.ArrayElement, T>) -> ArrayElementKeyPath<Self, T> {
    .init(.first, self, keyPath)
  }

  public func last<T>(_ keyPath: KeyPath<Value.ArrayElement, T>) -> ArrayElementKeyPath<Self, T> {
    .init(.last, self, keyPath)
  }
}

extension Expression where Value: AnyArrayOrSet {
  public var size: Function<Self, Int> {
    .size(self)
  }

  public var count: Function<Self, Int> {
    .count(self)
  }
}

extension Expression where Value: AnyArrayOrSet & AdditiveCollection {
  public var average: Function<Self, Value.AdditiveElement> {
    .average(self)
  }

  public var mode: Function<Self, Value.AdditiveElement> {
    .mode(self)
  }

  public var sum: Function<Self, Value.AdditiveElement> {
    .sum(self)
  }
}

extension Expression where Value: AnyArrayOrSet & ComparableCollection {
  public var min: Function<Self, Value.ComparableElement> {
    .min(self)
  }

  public var max: Function<Self, Value.ComparableElement> {
    .max(self)
  }
}

// MARK: - Sub-predicates

/// Creates a query to filter the collection of objects represented by the specified key-path.
///
/// - Parameters:
///   - keyPath: The key-path representing the collection to filter. The value of this key-path must be a valid
///     collection (an array or a set).
///   - predicate: The predicate to use to filter the collection.
///
/// - Returns: A query returning an array of objects matching the specified predicate. The returned query
///   can be composed in more complex predicates.
///
/// ###### Example
///
///       (\Account.name).contains("Account") && all(\.profiles, where: (\Profile.name).contains("Doe")).size == 2)
///
public func all<T, U: AnyArrayOrSet>(_ keyPath: KeyPath<T, U>, where predicate: Predicate<U.Element>) -> Query<T, U> {
  .init(key: keyPath, predicate: predicate)
}

// MARK: - Boolean predicates

extension Predicate: ExpressibleByBooleanLiteral {
  public init(booleanLiteral value: Bool) {
    self = .boolean(value)
  }
}

// MARK: - Type-erased Types

struct AnyExpression {
  let toNSExpression: (NSExpressionConversionOptions) -> NSExpression
  let comparisonModifier: ComparisonModifier
  private let expression: Any

  init<E: Expression>(_ expression: E) {
    self.comparisonModifier = expression.comparisonModifier
    self.expression = expression
    self.toNSExpression = { options in
      guard let expression = expression as? NSExpressionConvertible else {
        fatalError("\(String(describing: E.self)) does not conform to NSExpressionConvertible.")
      }

      return expression.toNSExpression(options: options)
    }
  }

  func `as`<E: Expression>(_ type: E.Type) -> E? {
    return expression as? E
  }
}

extension Expression {
  public var comparisonModifier: ComparisonModifier { .direct }
}

// MARK: - Supporting Protocols

// MARK: - StringValue

public protocol StringValue {
}

extension String: StringValue {
}

extension Optional: StringValue where Wrapped == String {
}

// MARK: - AnyArrayOrSet

public protocol AnyArrayOrSet {
  associatedtype Element
}

extension Array: AnyArrayOrSet {
}

extension Set: AnyArrayOrSet {
}

extension NSSet: AnyArrayOrSet {
}

extension Optional: AnyArrayOrSet where Wrapped: AnyArrayOrSet {
  public typealias Element = Wrapped.Element
}

// MARK: - AnyArray

public protocol AnyArray {
  associatedtype ArrayElement
}

extension Array: AnyArray {
  public typealias ArrayElement = Element
}

extension Optional: AnyArray where Wrapped: AnyArray {
  public typealias ArrayElement = Wrapped.ArrayElement
}

// MARK: - PrimitiveCollection

public protocol PrimitiveCollection {
  associatedtype PrimitiveElement: Primitive
}

extension Array: PrimitiveCollection where Element: Primitive {
  public typealias PrimitiveElement = Element
}

extension Set: PrimitiveCollection where Element: Primitive {
  public typealias PrimitiveElement = Element
}

extension Optional: PrimitiveCollection where Wrapped: PrimitiveCollection {
  public typealias PrimitiveElement = Wrapped.PrimitiveElement
}

// MARK: - AdditiveCollection

public protocol AdditiveCollection {
  associatedtype AdditiveElement: AdditiveArithmetic & Primitive
}

extension Array: AdditiveCollection where Element: AdditiveArithmetic & Primitive {
  public typealias AdditiveElement = Element
}

extension Optional: AdditiveCollection where Wrapped: PrimitiveCollection & AdditiveCollection {
  public typealias AdditiveElement = Wrapped.AdditiveElement
}

// MARK: - ComparableCollection

public protocol ComparableCollection {
  associatedtype ComparableElement: Comparable & Primitive
}

extension Array: ComparableCollection where Element: Comparable & Primitive {
  public typealias ComparableElement = Element
}

extension Optional: ComparableCollection where Wrapped: ComparableCollection {
  public typealias ComparableElement = Wrapped.ComparableElement
}

// MARK: - Private Initializers

extension Comparison {
  fileprivate init<E: Expression, P: Primitive>(
    _ expression: E,
    _ `operator`: ComparisonOperator,
    _ value: P
  ) {
    self.expression = AnyExpression(expression)
    self.operator = `operator`
    self.value = value
    self.options = P.defaultComparisonOptions
  }

  fileprivate init<E: Expression>(
    _ expression: E,
    _ `operator`: ComparisonOperator,
    _ value: Primitive,
    _ options: ComparisonOptions
  ) {
    self.expression = AnyExpression(expression)
    self.operator = `operator`
    self.value = value
    self.options = options
  }

  var modifier: ComparisonModifier {
    expression.comparisonModifier
  }
}

extension ArrayElementKeyPath {
  fileprivate init(
    _ type: ArrayElementKeyPathType,
    _ array: Array,
    _ elementKeyPath: AnyKeyPath
  ) {
    self.type = type
    self.array = array
    self.elementKeyPath = elementKeyPath
  }

  public var comparisonModifier: ComparisonModifier {
    switch type {
    case .first, .last, .index:
      return .direct
    case .all:
      return .all
    case .any:
      return .any
    case .none:
      return .none
    }
  }
}

extension Primitive {
  static var defaultComparisonOptions: ComparisonOptions {
    switch type {
    case .uuid:
      return .none

    // TODO: Add proper defaults for the other types.
    // For now, .caseInsensitive does not seem to hurt?
    default:
      return .caseInsensitive
    }
  }
}

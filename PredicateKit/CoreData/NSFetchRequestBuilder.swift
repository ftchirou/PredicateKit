//
//  NSFetchRequestBuilder.swift
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

import CoreData
import Foundation

protocol NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression
}

struct NSExpressionConversionOptions {
  let keyPathsPrefix: String?
}

struct NSFetchRequestBuilder {
  struct Options {
    let keyPathsPrefix: String?
  }

  private let entityName: String
  private let options: Options

  init(entityName: String, options: Options = .init(keyPathsPrefix: nil)) {
    self.entityName = entityName
    self.options = options
  }

  func makeRequest<Entity: NSManagedObject, Result: NSFetchRequestResult>(
    from request: FetchRequest<Entity>
  ) -> NSFetchRequest<Result> {
    let fetchRequest = NSFetchRequest<Result>(entityName: entityName)

    fetchRequest.predicate = makePredicate(from: request.predicate)
    fetchRequest.sortDescriptors = request.sortCriteria.map(makeSortDescriptor)
    request.limit.flatMap { fetchRequest.fetchLimit = $0 }
    request.offset.flatMap { fetchRequest.fetchOffset = $0 }
    request.batchSize.flatMap { fetchRequest.fetchBatchSize = $0 }
    request.propertiesToPrefetch.flatMap { fetchRequest.relationshipKeyPathsForPrefetching = $0.map {$0.stringValue } }
    request.includesPendingChanges.flatMap { fetchRequest.includesPendingChanges = $0 }
    request.affectedStores.flatMap { fetchRequest.affectedStores = $0 }
    request.propertiesToFetch.flatMap { fetchRequest.propertiesToFetch = $0.map { $0.stringValue } }
    request.returnsDistinctResults.flatMap { fetchRequest.returnsDistinctResults = $0 }
    request.shouldRefreshRefetchedObjects.flatMap { fetchRequest.shouldRefreshRefetchedObjects = $0 }
    request.propertiesToGroupBy.flatMap { fetchRequest.propertiesToGroupBy = $0.map { $0.stringValue } }
    request.havingPredicate.flatMap { fetchRequest.havingPredicate = makePredicate(from: $0) }
    request.includesSubentities.flatMap { fetchRequest.includesSubentities = $0 }
    request.returnsObjectsAsFaults.flatMap { fetchRequest.returnsObjectsAsFaults = $0 }
    
    return fetchRequest
  }

  fileprivate func makePredicate<Root>(from predicate: Predicate<Root>) -> NSPredicate {
    switch predicate {
    case let .comparison(comparison):
      switch comparison.modifier {
      case .direct, .any, .all:
        return NSComparisonPredicate(
          leftExpression: makeExpression(from: comparison.expression),
          rightExpression: makeExpression(from: comparison.value),
          modifier: makeComparisonModifier(from: comparison.modifier),
          type: makeOperator(from: comparison.operator),
          options: makeComparisonOptions(from: comparison.options)
        )
      case .none:
        return NSCompoundPredicate(notPredicateWithSubpredicate: NSComparisonPredicate(
          leftExpression: makeExpression(from: comparison.expression),
          rightExpression: makeExpression(from: comparison.value),
          modifier: makeComparisonModifier(from: comparison.modifier),
          type: makeOperator(from: comparison.operator),
          options: makeComparisonOptions(from: comparison.options)
        ))
      }
    case let .boolean(value):
      return NSPredicate(value: value)
    case let .and(lhs, rhs):
      return NSCompoundPredicate(andPredicateWithSubpredicates: [
        makePredicate(from: lhs),
        makePredicate(from: rhs)
      ])
    case let .or(lhs, rhs):
      return NSCompoundPredicate(orPredicateWithSubpredicates: [
        makePredicate(from: lhs),
        makePredicate(from: rhs)
      ])
    case let .not(predicate):
      return NSCompoundPredicate(notPredicateWithSubpredicate: makePredicate(
        from: predicate
      ))
    }
  }

  private func makeExpression(from expression: AnyExpression) -> NSExpression {
    expression.toNSExpression(conversionOptions)
  }

  private func makeExpression(from primitive: Primitive) -> NSExpression {
    return NSExpression(forConstantValue: primitive.predicateValue)
  }

  private func makeOperator(from operator: ComparisonOperator) -> NSComparisonPredicate.Operator {
    switch `operator` {
    case .beginsWith:
      return .beginsWith
    case .between:
      return .between
    case .contains:
      return .contains
    case .endsWith:
      return .endsWith
    case .equal:
      return .equalTo
    case .greaterThan:
      return .greaterThan
    case .greaterThanOrEqual:
      return .greaterThanOrEqualTo
    case .in:
      return .in
    case .lessThan:
      return .lessThan
    case .lessThanOrEqual:
      return .lessThanOrEqualTo
    case .like:
      return .like
    case .matches:
      return .matches
    case .notEqual:
      return .notEqualTo
    }
  }

  private func makeComparisonOptions(from options: ComparisonOptions) -> NSComparisonPredicate.Options {
    var comparisonOptions = NSComparisonPredicate.Options()

    if options.contains(.caseInsensitive) {
      comparisonOptions.formUnion(.caseInsensitive)
    }

    if options.contains(.diacriticInsensitive) {
      comparisonOptions.formUnion(.diacriticInsensitive)
    }

    if options.contains(.normalized) {
      comparisonOptions.formUnion(.normalized)
    }

    return comparisonOptions
  }

  private func makeSortDescriptor<T>(from sortCriterion: FetchRequest<T>.SortCriterion<T>) -> NSSortDescriptor {
    guard let comparator = sortCriterion.comparator else {
      return NSSortDescriptor(
        key: sortCriterion.property.stringValue,
        ascending: sortCriterion.order == .ascending
      )
    }
    
    return NSSortDescriptor(
      key: sortCriterion.property.stringValue,
      ascending: sortCriterion.order == .ascending,
      comparator: { lhs, rhs in
        guard let lhs = lhs as? T, let rhs = rhs as? T else {
          return .orderedDescending
        }
        
        return comparator(lhs, rhs)
      }
    )
  }

  private func makeComparisonModifier(from modifier: ComparisonModifier) -> NSComparisonPredicate.Modifier {
    switch modifier {
    case .direct:
      return .direct
    case .all:
      return .all
    case .any:
      return .any
    case .none:
      return .any
    }
  }

  private var conversionOptions: NSExpressionConversionOptions {
    .init(keyPathsPrefix: options.keyPathsPrefix)
  }
}

// MARK: - ComparisonResult

extension ComparisonResult {
  static let `default`: ComparisonResult = .orderedDescending
}

// MARK: - NSExpressionConvertibles

extension KeyPath: NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression {
    return NSExpression(forKeyPath: options.keyPathsPrefix.flatMap { "\($0).\(stringValue)" } ?? stringValue)
  }
}

extension ArrayElementKeyPath: NSExpressionConvertible where Array: NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression {
    let value: String = {
      switch type {
      case .any, .all, .none:
        return "\(array.toNSExpression(options: options)).\(elementKeyPath.stringValue)"
      case .first:
        return "\(array.toNSExpression(options: options))[FIRST].\(elementKeyPath.stringValue)"
      case .last:
        return "\(array.toNSExpression(options: options))[LAST].\(elementKeyPath.stringValue)"
      case let .index(index):
        return "\(array.toNSExpression(options: options))[\(index)].\(elementKeyPath.stringValue)"
      }
    }()

    return NSExpression(format: value.replacingOccurrences(of: ".self", with: ""))
  }
}

extension Index: NSExpressionConvertible where Array: NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression {
    switch self {
    case let .index(expression, index):
      return NSExpression(format: "(\(expression.toNSExpression(options: options)))[\(index)]")
    case let .first(expression):
      return NSExpression(format: "(\(expression.toNSExpression(options: options)))[FIRST]")
    case let .last(expression):
      return NSExpression(format: "(\(expression.toNSExpression(options: options)))[LAST]")
    }
  }
}

extension Function: NSExpressionConvertible where Input: NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression {
    switch self {
    case let .average(expression):
      return NSExpression(
        forFunction: "average:",
        arguments: [expression.toNSExpression(options: options)]
      )
    case let .count(expression):
      return NSExpression(
        forFunction: "count:",
        arguments: [expression.toNSExpression(options: options)]
      )
    case let .sum(expression):
      return NSExpression(
        forFunction: "sum:",
        arguments: [expression.toNSExpression(options: options)]
      )
    case let .min(expression):
      return NSExpression(
        forFunction: "min:",
        arguments: [expression.toNSExpression(options: options)]
      )
    case let .max(expression):
      return NSExpression(
        forFunction: "max:",
        arguments: [expression.toNSExpression(options: options)]
      )
    case let .mode(expression):
      return NSExpression(
        forFunction: "mode:",
        arguments: [expression.toNSExpression(options: options)]
      )
    case let .size(expression):
      return NSExpression(format: "(\(expression.toNSExpression(options: options)))[SIZE]")
    }
  }
}

extension Query: NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression {
    let builder = NSFetchRequestBuilder(
      entityName: "",
      options: NSFetchRequestBuilder.Options(keyPathsPrefix: "$x")
    )

    return NSExpression(
      forSubquery: NSExpression(forKeyPath: key.stringValue),
      usingIteratorVariable: "x",
      predicate: builder.makePredicate(from: predicate)
    )
  }
}

extension ObjectIdentifier: NSExpressionConvertible where Object: NSExpressionConvertible {
  func toNSExpression(options: NSExpressionConversionOptions) -> NSExpression {
    let root = self.root.toNSExpression(options: options)
    return NSExpression(format: "\(root).id")
  }
}

// MARK: - KeyPath

extension AnyKeyPath {
  var stringValue: String {
    // https://github.com/apple/swift/blob/swift-5.9.2-RELEASE/stdlib/public/core/KeyPath.swift#L191
    guard let value = _kvcKeyPathString else {
      fatalError("Could not create a string representation of the key path \(self).")
    }
    
    return value
  }
}

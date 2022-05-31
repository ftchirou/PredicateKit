//
//  NSManagedObjectContextExtensions.swift
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

extension NSManagedObjectContext {
  /// Creates a request to fetch a list of objects matching the specified [predicate](x-source-tag://Predicate).
  ///
  /// - Parameter predicate: The predicate to use to filter the objects in the underlying CoreData store.
  ///
  /// - Returns: A [FetchRequest](x-source-tag://FetchRequest) that can be customized further using modifiers or executed immediately.
  ///
  /// ## Example
  ///
  ///     // Returns an array of `Note` (an `NSManagedObject` subclass).
  ///     let notes: [Note] = try managedObjectContext
  ///       .fetch(where: (\Note.text).contains("Hello, World!"))
  ///       .sorted(by: \.creationDate, .descending)
  ///       .result()
  ///
  ///     // Returns an array of `[String: Any]`, each containing only the keys `text` and `creationDate`.
  ///     let dictionaries: [[String: Any]] = try managedObjectContext
  ///       .fetch(where: (\Note.text).contains("Hello, World!"))
  ///       .sorted(by: \.creationDate, .descending)
  ///       .fetchingOnly(\.text, \.creationDate)
  ///
  public func fetch<Entity>(where predicate: Predicate<Entity>) -> FetchRequest<Entity> {
    .init(context: self, predicate: predicate)
  }

  /// Counts the number of objects matching the specified [predicate](x-source-tag://Predicate).
  ///
  /// - Parameter predicate: The predicate to use to match the objects included in the count.
  ///
  /// - Returns: The number of objects matching the specified predicate.
  ///
  /// ## Example
  ///
  ///     let count = try managedObjectContext.count(
  ///       where: (\Account.purchases).average >= 120.0
  ///     )
  ///
  public func count<Entity: NSManagedObject>(where predicate: Predicate<Entity>) throws -> Int {
    let request = FetchRequest<Entity>(context: self, predicate: predicate)
    return try request.count()
  }

  /// Creates a request to fetch all the objects represented by the entity `Entity`.
  ///
  ///
  /// - Returns: A [FetchRequest](x-source-tag://FetchRequest) that can be customized further using modifiers or executed immediately.
  ///
  /// ## Example
  ///
  ///     let notes: [Note] = try managedObjectContext
  ///       .fetchAll()
  ///       .sorted(by: \.creationDate, .descending)
  ///       .result()
  ///
  public func fetchAll<Result>() -> FetchRequest<Result> {
    fetch(where: true)
  }

  /// Counts all the objects represented by the entity `Entity`.
  ///
  /// - Returns: The number of stored objects represented by the entity `Entity`.
  ///
  /// ## Example
  ///
  ///     let count = try managedObjectContext.countAll()
  ///
  public func countAll<Entity: NSManagedObject>(_: Entity.Type) throws -> Int {
    let predicate: Predicate<Entity> = true
    return try count(where: predicate)
  }
}

// MARK: - FetchRequest

// Tag: - FetchRequest
///
/// Represents a set of rules describing how to filter and retrieve a a list of objects of type `Entity`
/// from CoreData persistent stores.
///
/// You create a `FetchRequest` by calling the function `fetch(where:)` on an object of type `NSManagedObjectContext`.
/// The resulting `FetchRequest` can be customized using modifiers and/or executed using the `result()` function.
///
/// # Example
///
///     let notes: [Note] = try managedObjectContext
///        .fetch(where: (\Note.text).contains("Hello, World!"))
///        // Apply the `sorted(by:)` modifier.
///        .sorted(by: \.creationDate, .descending)
///        // Execute the `FetchRequest`.
///        .result()
///
///  # See also:
///  [NSFetchRequest](https://developer.apple.com/documentation/coredata/nsfetchrequest)
///
public struct FetchRequest<Entity: NSManagedObject> {
  /// Represents a sorting criterion that determines how objects of type `T` should be sorted.
  public struct SortCriterion<T> {
    /// A custom comparator for objects of type `T`.
    public typealias Comparator = (T, T) -> ComparisonResult

    public enum Order {
      case ascending
      case descending
    }

    let property: PartialKeyPath<T>
    let order: Order
    let comparator: Comparator?

    init(property: PartialKeyPath<T>, order: Order = .ascending, comparator: Comparator? = nil) {
      self.property = property
      self.order = order
      self.comparator = comparator
    }
  }

  private let context: NSManagedObjectContext
  private(set) var predicate: Predicate<Entity>
  private(set) var sortCriteria: [SortCriterion<Entity>] = []
  private(set) var limit: Int?
  private(set) var offset: Int?
  private(set) var batchSize: Int?
  private(set) var propertiesToPrefetch: [PartialKeyPath<Entity>]?
  private(set) var includesPendingChanges: Bool?
  private(set) var affectedStores: [NSPersistentStore]?
  private(set) var propertiesToFetch: [PartialKeyPath<Entity>]?
  private(set) var returnsDistinctResults: Bool?
  private(set) var shouldRefreshRefetchedObjects: Bool?
  private(set) var propertiesToGroupBy: [PartialKeyPath<Entity>]?
  private(set) var havingPredicate: Predicate<Entity>?
  private(set) var includesSubentities: Bool?
  private(set) var returnsObjectsAsFaults: Bool?
  private(set) var debugInspector: NSFetchRequestInspector?

  private var requestBuilder: NSFetchRequestBuilder {
    .init(entityName: entityName)
  }

  init(context: NSManagedObjectContext, predicate: Predicate<Entity>) {
    self.context = context
    self.predicate = predicate
  }

  // MARK: - Request Modifiers

  /// Specifies how many objects are returned by the fetch request.
  ///
  /// # See also:
  /// [fetchLimit](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506622-fetchlimit)
  ///
  public func limit(_ value: Int) -> Self {
    updating(\.limit, with: value)
  }

  /// Specifies how many matching objects are skipped before the rest of matching objects is returned.
  ///
  /// # See also:
  /// [fetchOffset](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506770-fetchoffset)
  public func offset(_ value: Int) -> Self {
    updating(\.offset, with: value)
  }

  /// Specifies the batch size of the objects in the fetch request.
  ///
  /// # See also:
  /// [fetchBatchSize](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506558-fetchbatchsize)
  ///
  public func batchSize(_ value: Int) -> Self {
    updating(\.batchSize, with: value)
  }

  /// Specifies the key-paths of the relationships to prefetch along with objects of the fetch request.
  ///
  /// # See also:
  /// [relationshipKeyPathsForPrefetching](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506813-relationshipkeypathsforprefetchi)
  ///
  public func prefetchingRelationships(_ relationships: PartialKeyPath<Entity>...) -> Self {
    updating(\.propertiesToPrefetch, with: relationships)
  }

  /// Specifies whether changes unsaved in the managed object context are included in the result of the fetch request.
  ///
  /// # See also:
  /// [includesPendingChanges](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506724-includespendingchanges)
  public func includingPendingChanges(_ includesPendingChanges: Bool) -> Self {
    updating(\.includesPendingChanges, with: includesPendingChanges)
  }

  /// Specifies the persistent stores to be searched when the fetch request is executed.
  ///
  /// # See also:
  /// [affectedStores](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506518-affectedstores)
  ///
  public func fromStores(_ affectedStores: NSPersistentStore...) -> Self {
    updating(\.affectedStores, with: affectedStores)
  }

  /// Specifies the key-paths of the properties on `Entity` to fetch.
  ///
  /// # See also:
  /// [propertiesToFetch](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506851-propertiestofetch)
  ///
  public func fetchingOnly(_ keyPaths: PartialKeyPath<Entity>...) -> Self {
    updating(\.propertiesToFetch, with: keyPaths)
  }

  /// Specifies whether the fetch request returns only distinct values for the key-paths specified by `fetchingOnly(_:)`.
  ///
  /// # See also:
  /// [returnsDistinctResults](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506344-returnsdistinctresults)
  ///
  public func returningDistinctResults(_ returnsDistinctResults: Bool) -> Self {
    updating(\.returnsDistinctResults, with: returnsDistinctResults)
  }

  /// Specifies the key-paths of the properties to group the result by.
  ///
  /// Applying this modifier requires that the result of the request is of type `[[String: Any]]`.
  ///
  /// # See also:
  /// [propertiesToGroupBy](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506191-propertiestogroupby)
  ///
  public func groupBy(_ keyPaths: PartialKeyPath<Entity>...) -> Self {
    updating(\.propertiesToGroupBy, with: keyPaths)
  }

  /// Specifies whether the property values of fetched objects will be updated with the current values in the persistent store.
  ///
  /// # See also:
  /// [shouldRefreshRefetchedObjects](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506440-shouldrefreshrefetchedobjects)
  ///
  public func refreshingRefetchedObjects(_ shouldRefreshRefetchedObjects: Bool) -> Self {
    updating(\.shouldRefreshRefetchedObjects, with: shouldRefreshRefetchedObjects)
  }

  /// Specifies the predicate to use to filter objects returned by a request with a `groupBy(_:)` modifier applied.
  ///
  /// Applying this modifier requires that the `groupBy(_:)` modifier is applied as well.
  ///
  /// # See also:
  /// [havingPredicate](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506429-havingpredicate)
  ///
  public func having(_ predicate: Predicate<Entity>) -> Self {
    updating(\.havingPredicate, with: predicate)
  }

  /// Specifies whether subentities are included in the result.
  ///
  /// # See also:
  /// [includesSubentities](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506366-includessubentities)
  ///
  public func includingSubentities(_ includesSubentities: Bool) -> Self {
    updating(\.includesSubentities, with: includesSubentities)
  }

  /// Specifies whether objects returned from the fetch request are faults.
  ///
  /// # See also:
  /// [returnsObjectsAsFaults](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506756-returnsobjectsasfaults)
  ///
  public func returningObjectsAsFaults(_ returnsObjectsAsFaults: Bool) -> Self {
    updating(\.returnsObjectsAsFaults, with: returnsObjectsAsFaults)
  }

  /// Specifies how the objects returned by the request should be sorted.
  ///
  /// - Parameters:
  ///    - property: The key-path by which to sort the objects.
  ///    - order: The order in which to sort the objects. Defaults to `.ascending`.
  ///    - comparator: A custom comparator to use to sort the objects. If set to `nil`, the objects
  ///      are compared with the default `<` opeator. Defaults to `nil`.
  ///
  public func sorted<Value: Comparable & Primitive>(
    by property: KeyPath<Entity, Value>,
    _ order: SortCriterion<Entity>.Order = .ascending,
    using comparator: SortCriterion<Entity>.Comparator? = nil
  ) -> Self {
    updating(\.sortCriteria, with: sortCriteria + [.init(property: property, order: order, comparator: comparator)])
  }

  /// Specifies an object that can inspect the underlying `NSFetchRequest` objects in debug environments.
  ///
  /// Applying this modifier is valid only in debug environment and has no effect in a release one.
  ///
  public func inspect(on inspector: NSFetchRequestInspector) -> Self {
    #if DEBUG
    return updating(\.debugInspector, with: inspector)
    #else
    return self
    #endif
  }

  // MARK: -

  /// Executes the fetch request.
  ///
  /// - Returns: An array of objects of type `Entity` matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///      let notes: [Note] = try managedObjectContext
  ///        .fetch(where: (\Note.text).contains("Hello, World!"))
  ///        .sorted(by: \.creationDate, .descending)
  ///        .result()
  ///
  public func result() throws -> [Entity] {
    let request: NSFetchRequest<Entity> = requestBuilder.makeRequest(from: self)
    request.resultType = .managedObjectResultType
    #if DEBUG
    debugInspector?.inspect(request.copy() as! NSFetchRequest<Entity>)
    #endif
    return try context.fetch(request)
  }
  
  // MARK: -
  
  /// Executes the fetch request.
  ///
  /// - Returns: An array of objects of type `Entity` matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///      let notes: [Note] = try managedObjectContext
  ///        .fetch(where: (\Note.text).contains("Hello, World!"))
  ///        .sorted(by: \.creationDate, .descending)
  ///        .entityResult()
  ///
  public func entityResult() throws -> [Entity] {
    try result()
  }
  
  /// Executes the fetch request.
  ///
  /// - Returns: An array of `[String: Any]` containing the keys or a subset of the keys of the objects of type `Entity`
  ///   matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///     let dictionaries: [[String: Any]] = try managedObjectContext
  ///        .fetch(where: (\Note.text).contains("Hello, World!"))
  ///        .sorted(by: \.creationDate, .descending)
  ///        .fetchingOnly(\.text, \.creationDate)
  ///
  public func result() throws -> [[String: Any]] {
    let request: NSFetchRequest<NSDictionary> = requestBuilder.makeRequest(from: self)
    request.resultType = .dictionaryResultType
    #if DEBUG
    debugInspector?.inspect(request.copy() as! NSFetchRequest<NSDictionary>)
    #endif
    return try context.fetch(request) as! [[String: Any]]
  }

  /// Executes the fetch request.
  ///
  /// - Returns: An array of `[String: Any]` containing the keys or a subset of the keys of the objects of type `Entity`
  ///   matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///     let dictionaries: [[String: Any]] = try managedObjectContext
  ///        .fetch(where: (\Note.text).contains("Hello, World!"))
  ///        .sorted(by: \.creationDate, .descending)
  ///        .fetchingOnly(\.text, \.creationDate)
  ///        .dictionaryResult()
  ///
  public func dictionaryResult() throws -> [[String: Any]] {
    try result()
  }
  
  /// Counts the number of objects matching the criteria specified by the fetch request.
  ///
  /// - Returns: The number of objects matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///     let count = try managedObjectContext.count(
  ///       where: (\Account.purchases).average >= 120.0
  ///     )
  ///
  public func count() throws -> Int {
    let request: NSFetchRequest<Entity> = requestBuilder.makeRequest(from: self)
    #if DEBUG
    debugInspector?.inspect(request.copy() as! NSFetchRequest<Entity>)
    #endif
    return try context.count(for: request)
  }
  
  /// Returns an NSFetchedResultsController initialized with the fetch request.
  ///
  /// - Parameters:
  ///    - cacheName - Pre-computed section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor. Defaults to `nil`.
  ///
  /// - Returns: A fetchedResultsController with objects of type `Entity` matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///      let notes: NSFetchedResultsController<Note> = managedObjectContext
  ///        .fetch(where: (\Note.text).contains("Hello, World!"))
  ///        .sorted(by: \.creationDate, .descending)
  ///        .fetchedResultsController()
  ///
  public func fetchedResultsController(cacheName: String? = nil) -> NSFetchedResultsController<Entity> {
    fetchedResultsController(sectionNameKeyPath: nil, cacheName: cacheName)
  }
  
  /// Returns an NSFetchedResultsController initialized with the fetch request.
  ///
  /// - Parameters:
  ///    - sectionNameKeyPath - A key path on resulting objects that returns the section name. This will be used to pre-compute the section information.
  ///    - cacheName - Pre-computed section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor. Defaults to `nil`.
  ///
  /// - Returns: An NSFetchedResultsController with objects of type `Entity` matching the criteria specified by the fetch request.
  ///
  /// ## Example
  ///
  ///      let notes: NSFetchedResultsController<Note> = managedObjectContext
  ///        .fetch(where: (\Note.text).contains("Hello, World!"))
  ///        .sorted(by: \.creationDate, .descending)
  ///        .fetchedResultsController(sectionNameKeyPath: \.creationDate)
  ///
  public func fetchedResultsController<T: Comparable & Primitive>(
    sectionNameKeyPath: KeyPath<Entity, T>,
    cacheName: String? = nil
  ) -> NSFetchedResultsController<Entity> {
    fetchedResultsController(sectionNameKeyPath: sectionNameKeyPath.stringValue, cacheName: cacheName)
  }
  
  private func fetchedResultsController(
    sectionNameKeyPath: String?,
    cacheName: String? = nil
  ) -> NSFetchedResultsController<Entity> {
    let request: NSFetchRequest<Entity> = requestBuilder.makeRequest(from: self)
    request.resultType = .managedObjectResultType
    return NSFetchedResultsController(
      fetchRequest: request,
      managedObjectContext: context,
      sectionNameKeyPath: sectionNameKeyPath,
      cacheName: cacheName
    )
  }

  // MARK: -

  var entityName: String {
    return Entity.entity().name ?? String(describing: Entity.self)
  }

  private func updating<T>(_ keyPath: WritableKeyPath<FetchRequest<Entity>, T>, with value: T) -> Self {
    var result = self
    result[keyPath: keyPath] = value
    return result
  }
}

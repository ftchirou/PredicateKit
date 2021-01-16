# 🎯 PredicateKit
![GitHub Workflow Status (branch)](https://img.shields.io/github/workflow/status/ftchirou/PredicateKit/Test/main) <img src="https://img.shields.io/badge/coverage-100%25-green"> ![GitHub release (latest SemVer)](https://img.shields.io/github/v/release/ftchirou/PredicateKit) <img src="https://img.shields.io/badge/platforms-iOS%2011%2B%20%7C%20macOS%2010.15%2B%20%7C%20watchOS%205%2B%20%7C%20tvOS%2011%2B-lightgrey"> <img src="https://img.shields.io/badge/swift-%3E%3D%205.1-orange">

**PredicateKit** is an alternative to [`NSPredicate`](https://developer.apple.com/documentation/foundation/nspredicate) allowing you to 
write expressive and type-safe predicates for [CoreData](https://developer.apple.com/documentation/coredata) using [key-paths](https://developer.apple.com/documentation/swift/keypath),
comparisons and logical operators, literal values, and functions.

<img src="https://dl.dropboxusercontent.com/s/h8yeg34jb68vxfy/predicate-kit.png">

## Contents
- [Motivation](#motivation)
- [Installation](#installation)
  - [Carthage](#carthage)
  - [CocoaPods](#cocoapods)
  - [Swift Package Manager](#swift-package-manager)
- [Quick start](#quick-start)
  - [Fetching objects](#fetching-objects)
  - [Configuring the fetch](#configuring-the-fetch)
  - [Fetching objects with the @FetchRequest property wrapper](#fetching-objects-with-the-fetchrequest-property-wrapper)
  - [Fetching objects with an NSFetchedResultsController](#fetching-objects-with-an-nsfetchedresultscontroller)
  - [Counting objects](#counting-objects)
- [Documentation](#documentation)
  - [Writing predicates](#writing-predicates)
    - [Comparisons](#comparisons)
      - [Basic comparisons](#basic-comparisons)
      - [String comparisons](#string-comparisons)
      - [Membership checks](#membership-checks)
    - [Compound predicates](#compound-predicates)
      - [AND](#and-predicates)
      - [OR](#or-predicates)
      - [NOT](#not-predicates)
    - [Array operations](#array-operations)
      - [`first`](#first)
      - [`last`](#last)
      - [`at(index:)`](#atindex)
      - [`count` / `size`](#count)
      - [`sum`](#sum)
      - [`average`](#average)
      - [`min`](#min)
      - [`max`](#max)
      - [`all`](#all)
      - [`any`](#any)
      - [`none`](#none)
    - [Predicates with one-to-one relationships](#predicates-with-one-to-one-relationships)
    - [Predicates with one-to-many relationships](#predicates-with-one-to-many-relationships)
    - [Sub-predicates](#sub-predicates)
  - [Request modifiers](#request-modifiers)
    - [`limit`](#limit)
    - [`offset`](#offset)
    - [`batchSize`](#batchsize)
    - [`prefetchingRelationships`](#prefetchingrelationships)
    - [`includingPendingChanges`](#includingPendingChanges)
    - [`fromStores`](#fromstores)
    - [`fetchingOnly`](#fetchingonly)
    - [`returningDistinctResults`](#returningDistinctResults)
    - [`groupBy`](#groupby)
    - [`refreshingRefetchedObjects`](#refreshingrefetchedobjects)
    - [`having`](#having)
    - [`includingSubentities`](#includingsubentities)
    - [`returningObjectsAsFaults`](#returningobjectsasfaults)
    - [`sorted`](#sorted)
  - [Debugging](#debugging)

# Motivation

CoreData is a formidable piece of technology, however not all of its API has caught up with the modern Swift world. Specifically, fetching and filtering objects from
CoreData relies heavily on `NSPredicate` and `NSExpression`. Unfortunately, a whole range of bugs and runtime errors can easily be introduced using those APIs.
For instance, we can compare a property of type `String` to a value of type `Int` or even use a non-existant property in a predicate; these mistakes will go un-noticed
at compile time but can cause important errors at runtime that may not be obvious to diagnose. This is where **PredicateKit** comes in by making it virtually impossible to
introduce these types of errors.

Concretely, **PredicateKit** provides

- **a type-safe and expressive API** for writing predicates. When using PredicateKit, all properties involved in your predicates are expressed
using [key-paths](https://developer.apple.com/documentation/swift/keypath). This ensures that the usage of inexistant properties or typos are
caught at compile time. Additionally, all operations such as comparisons, functions calls, etc. are strongly-typed, making it impossible to write invalid predicates.
- **an improved developer experience**. Enjoy auto-completion and syntax highlighting when writing your predicates. In addition, PredicateKit
is just a lightweight replacement for `NSPredicate`, no major change to your codebase is required, no special protocol to conform to, no
configuration, etc. Simply `import PredicateKit`, write your predicates and use the functions [`NSManagedObjectContext.fetch(where:)`](#fetching-objects) or [`NSManagedObjectContext.count(where:)`](#counting-objects) to execute them.

# Installation

## Carthage

Add the following line to your `Cartfile`.

```
github "ftchirou/PredicateKit" ~> 1.0.0
```

## CocoaPods

Add the following line to your `Podfile`.

```
pod 'PredicateKit', ~> '1.0.0'
```

## Swift Package Manager

Update the `dependencies` array in your `Package.swift`.

```swift
dependencies: [
  .package(url: "https://github.com/ftchirou/PredicateKit", .upToNextMajor(from: "1.0.0"))
]
```

# Quick start

## Fetching objects

To fetch objects using PredicateKit, use the function `fetch(where:)` on an instance of `NSManagedObjectContext` passing as argument a predicate. `fetch(where:)` returns an object of type `FetchRequest` on which you call `result()` to execute the request and retrieve the matching objects.

###### Example

```swift
let notes: [Note] = try managedObjectContext
  .fetch(where: \Note.text == "Hello, World!" && \Note.creationDate < Date())
  .result()
```

You write your predicates using the [key-paths](https://developer.apple.com/documentation/swift/keypath) of the entity to filter and a combination of comparison and logical operators, literal values, and functions calls.

See [Writing predicates](#writing-predicates) for more about writing predicates.

### Fetching objects as dictionaries

By default, `fetch(where:)` returns an array of subclasses of `NSManagedObject`. You can specify that the objects be returned as an array of dictionaries (`[[String: Any]]`)
simply by changing the type of the variable storing the result of the fetch.

###### Example

```swift
let notes: [[String: Any]] = try managedObjectContext
  .fetch(where: \Note.text == "Hello, World!" && \Note.creationDate < Date())
  .result()
```

## Configuring the fetch

`fetch(where:)` returns an object of type `FetchRequest`. You can apply a series of modifiers on this object to further configure how the objects should be matched and returned.
For example, `sorted(by: \Note.creationDate, .descending)` is a modifier specifying that the objects should be sorted by the creation date in the descending order. A modifier returns a mutated `FetchRequest`; a series
of modifiers can be chained together to create the final `FetchRequest`.

###### Example

```swift
let notes: [Note] = try managedObjectContext
  .fetch(where: (\Note.text).contains("Hello, World!") && \Note.creationDate < Date())
  .limit(50) // Return 50 objects matching the predicate.
  .offset(100) // Skip the first 100 objects matching the predicate.
  .sorted(by: \Note.creationDate) // Sort the matching objects by their creation date.
  .result()
```

See [Request modifiers](#request-modifiers) for more about modifiers.

## Fetching objects with the @FetchRequest property wrapper

PredicateKit extends the SwiftUI [ `@FetchRequest`](https://developer.apple.com/documentation/swiftui/fetchrequest) property wrapper to support type-safe predicates. To use, simply initialize a `@FetchRequest` with a predicate.

###### Example

```swift
import PredicateKit
import SwiftUI

struct ContentView: View {

  @SwiftUI.FetchRequest(predicate: \Note.text == "Hello, World!")
  var notes: FetchedResults<Note>

  var body: some View {
    List(notes, id: \.self) {
      Text($0.text)
    }
  }
}
```

You can also initialize a `@FetchRequest` with a full-fledged request with modifiers and sort descriptors.

###### Example

```swift
import PredicateKit
import SwiftUI

struct ContentView: View {

  @SwiftUI.FetchRequest(
    fetchRequest: FetchRequest(predicate: (\Note.text).contains("Hello, World!"))
      .limit(50)
      .offset(100)
      .sorted(by: \.Note.creationDate)
  )
  var notes: FetchedResults<Note>

  var body: some View {
    List(notes, id: \.self) {
      Text($0.text)
    }
  }
}
```

Both initializers accept an optional parameter [`animation`](https://developer.apple.com/documentation/swiftui/animation) that will be used to animate changes in the fetched results.

###### Example

```swift
import PredicateKit
import SwiftUI

struct ContentView: View {

  @SwiftUI.FetchRequest(
    predicate: (\Note.text).contains("Hello, World!"),
    animation: .easeInOut
  )
  var notes: FetchedResults<Note>

  var body: some View {
    List(notes, id: \.self) {
      Text($0.text)
    }
  }
}
```

## Fetching objects with an NSFetchedResultsController

In UIKit, you can use `fetchedResultsController()` to create an `NSFetchedResultsController` from a configured fetch request. `fetchedResultsController` has two optional parameters: `sectionNameKeyPath` is a [key-path](https://developer.apple.com/documentation/swift/keypath) on the returned objects used to compute section info and `cacheName` is the name of a file to store pre-computed section info.

###### Example

```swift
let controller: NSFetchedResultsController<Note> = managedObjectContext
  .fetch(where: \Note.text == "Hello, World!" && \Note.creationDate < Date())
  .sorted(by: \Note.creationDate, .descending)
  .fetchedResultsController(sectionNameKeyPath: \Note.creationDate)
```

## Counting objects

To count the number of objects matching a predicate, use the function `count(where:)` on an instance of `NSManagedObjectContext`.

###### Example

```swift
let count = try managedObjectContext.count(where: (\Note.text).beginsWith("Hello"))
```

# Documentation

## Writing predicates

Predicates are expressed using a combination of comparison operators and logical operators, literal values, and functions.

### Comparisons

#### Basic comparisons

A comparison can be expressed using one of the basic comparison operators `<`, `<=`, `==`, `>=`, and `>` where the left hand side of
the operator is a [key-path](https://developer.apple.com/documentation/swift/keypath) and the right hand side
of the operator is a value whose type matches the value type of the key-path on the left hand side.

###### Example

```swift
class Note: NSManagedObject {
  @NSManaged var text: String
  @NSManaged var creationDate: Date
  @NSManaged var numberOfViews: Int
  @NSManaged var tags: [String]
}

// Matches all notes where the text is equal to "Hello, World!".
let predicate = \Note.text == "Hello, World!"

// Matches all notes created before the current date.
let predicate = \Note.creationDate < Date()

// Matches all notes where the number of views is at least 120.
let predicate = \Note.numberOfViews >= 120
```

#### String comparisons

If the property to compare is of type `String`, comparisons can be additionally expressed with special functions such as `beginsWith`,
`contains`, or `endsWith`.

```swift
// Matches all notes where the text begins with the string "Hello".
let predicate = (\Note.text).beginsWith("Hello")

// Matches all notes where the text contains the string "Hello".
let predicate = (\Note.text).contains("Hello")

// Matches all notes where the text matches the specified regular expression.
let predicate = (\Note.text).matches(NSRegularExpression(...))
```
Any of the following functions can be used in a string comparison predicate.

- `beginsWith`
- `contains`
- `endsWith`
- `like`
- `matches`

These functions accept a second optional parameter specifying how the string comparison should be performed.

```swift
// Case-insensitive comparison.
let predicate = (\Note.text).beginsWith("Hello, World!", .caseInsensitive)

// Diacritic-insensitive comparison.
let predicate = (\Note.text).beginsWith("Hello, World!", .diacriticInsensitive)

// Normalized comparison.
let predicate = (\Note.text).beginsWith("Hello, World!", .normalized)
```

#### Membership checks

###### between

You can use the `between` function or the `~=` operator to determine whether a property's value is within a specified range.

```swift
// Matches all notes where the number of views is between 100 and 200.
let predicate = (\Note.numberOfViews).between(100...200)

// Or
let predicate = \Note.numberOfViews ~= 100...200
```

###### in

You can use the  `in`  function to determine whether a property's value is one of the values in a specified list.


```swift
// Matches all notes where the text is one of the elements in the specified list.
let predicate = (\Note.text).in("a", "b", "c", "d")
```

When the property is of type `String`, `in` accepts a second parameter that determines how the string should be compared to the elements in the list.

```swift
// Case-insensitive comparison.
let predicate = (\Note.text).in(["a", "b", "c", "d"], .caseInsensitive)
```

### Compound predicates

Compound predicates are predicates that logically combine one, two or more predicates.

#### AND predicates

AND predicates are expressed with the `&&` operator where the operands are predicates. An AND predicate
matches objects where both its operands match.

```swift
// Matches all notes where the text begins with 'hello' and the number of views is at least 120.
let predicate = (\Note.text).beginsWith("hello") && \Note.numberOfViews >= 120
```

#### OR Predicates

OR predicates are expressed with the `||` operator where the operands are predicates. An OR predicate matches
objects where at least one of its operands matches.

```swift
// Matches all notes with the text containing 'hello' or created before the current date.
let predicate = (\Note.text).contains("hello") || \Note.creationDate < Date()
```

#### NOT Predicates

NOT predicates are expressed with the unary `!` operator with a predicate operand. A NOT predicate matches all objects
where its operand does not match.

```swift
// Matches all notes where the text is not equal to 'Hello, World!'
let predicate = !(\Note.text == "Hello, World!")
```

### Array operations

You can perform operations on properties of type `Array` (or expressions that evaluate to values of type `Array`) and use the result in a predicate.

#### Select an element in an array

###### first

```swift
// Matches all notes where the first tag is 'To Do'..
let predicate = (\Note.tags).first == "To Do"
```

###### last

```swift
// Matches all notes where the last tag is 'To Do'..
let predicate = (\Note.tags).last == "To Do"
```

###### at(index:)

```swift
// Matches all notes where the third tag contains 'To Do'.
let predicate = (\Note.tags).at(index: 2).contains("To Do")
```

#### Count the number of elements in an array

###### count

```swift
// Matches all notes where the number of elements in the `tags` array is less than 5.
let predicate = (\Note.tags).count < 5

// or

let predicate = (\Note.tags).size < 5
```

#### Combine the elements in an array

If the elements of an array are numbers, you can combine or reduce them into a single number and use the result in a predicate.

```swift
class Account: NSManagedObject {
  @NSManaged var purchases: [Double]
}
```

###### sum

```swift
// Matches all accounts where the sum of the purchases is less than 2000.
let predicate = (\Account.purchases).sum < 2000
```

###### average

```swift
// Matches all accounts where the average purchase is 120.0
let predicate = (\Account.purchases).average == 120.0
```

###### min

```swift
// Matches all accounts where the minimum purchase is 98.5.
let predicate = (\Account.purchases).min == 98.5
```

###### max

```swift
// Matches all accounts where the maximum purchase is at least 110.5.
let predicate = (\Account.purchases).max >= 110.5
```

#### Aggregate comparisons

You can also express predicates matching all, any, or none of the elements of an array.

###### all

```swift
// Matches all accounts where every purchase is at least 95.0
let predicate = (\Account.purchases).all >= 95.0
```

###### any

```swift
// Matches all accounts having at least one purchase of 20.0
let predicate = (\Account.purchases).any == 20.0
```

###### none

```swift
// Matches all accounts where no purchase is less than 50.
let predicate = (\Account.purchases).none <= 50
```

### Predicates with one-to-one relationships

If your object has a one-to-one relationship with another one, you can target any property of the relationship simply by
using the appropriate key-path.

###### Example

```swift
class User: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var billingInfo: BillingInfo
}

class BillingInfo: NSManagedObject {
  @NSManaged var accountType: String
  @NSManaged var purchases: [Double]
}

// Matches all users with the billing account type 'Pro'
let predicate = \User.billingInfo.accountType == "Pro"

// Matches all users with an average purchase of 120
let predicate = (\User.billingInfo.purchases).average == 120.0
```

### Predicates with one-to-many relationships

You can run aggregate operations on a set of relationships using the `all(_:)`, `any(_:)`, or `none(_:)` functions.

###### Example

```swift
class Account: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var profiles: Set<Profile>
}

class Profile: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var creationDate: String
}

// Matches all accounts where all the profiles have the creation date equal to the specified one.
let predicate = (\Account.profile).all(\.creationDate) == date

// Matches all accounts where any of the associated profiles has a name containing 'John'.
let predicate = (\Account.profiles).any(\.name).contains("John"))

// Matches all accounts where no profile has the name 'John Doe'
let predicate = (\Account.profiles).none(\.name) == "John Doe"
```

### Sub-predicates

When your object has one-to-many relationships, you can create a sub-predicate that filters the "many" relationships and use the
resuult of the sub-predicate in a more complex predicate. Sub-predicates are created using the global `all(_:where:)` function. The first
parameter is the key-path of the collection to filter and the second parameter is a predicate that filters the collection.

`all(_:where:)` evaluates to an array; that means you can perform any valid [array operation](#array-operations) on its result such as `size`, `first`, etc.

###### Example

```swift
// Matches all the accounts where the name contains 'Account' and where the number of profiles whose
// name contains 'Doe' is exactly 2.
let predicate = (\Account.name).contains("Account") 
  && all(\.profiles, where: (\Profile.name).contains("Doe")).size == 2)
```

## Request modifiers

You can configure how matching objects are returned by applying a chain of modifiers to the object returned by `NSManagedObjectContext.fetch(where:)`.

###### Example

```swift
let notes: [Note] = try managedObjectContext
  .fetch(where: (\Note.text).contains("Hello, World!") && \Note.creationDate < Date())
  .limit(50) // Return 50 objects matching the predicate.
  .offset(100) // Skip the first 100 objects matching the predicate.
  .sorted(by: \Note.text) // Sort the matching objects by their creation date.
  .result()
```

### limit

Specifies the number of objects returned by the fetch request.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .limit(50)
```

###### `NSFetchRequest` equivalent

[`fetchLimit`](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506622-fetchlimit)

### offset

Specifies the number of initial matching objects to skip.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .offset(100)
```

###### `NSFetchRequest` equivalent

[`fetchOffset`](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506770-fetchoffset)

### batchSize

Specifies the batch size of the objects in the fetch request.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .batchSize(80)
```

###### `NSFetchRequest` equivalent

[`fetchBatchSize`](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506558-fetchbatchsize)

### prefetchingRelationships

Specifies the key-paths of the relationships to prefetch along with objects of the fetch request.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .prefetchingRelationships(\.billingInfo, \.profiles)
```

###### `NSFetchRequest` equivalent

[`relationshipKeyPathsForPrefetching`](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506813-relationshipkeypathsforprefetchi)

### includingPendingChanges

Specifies whether changes unsaved in the managed object context are included in the result of the fetch request.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .includingPendingChanges(true)
```

###### `NSFetchRequest` equivalent

[`includesPendingChanges`](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506724-includespendingchanges)

### fromStores

Specifies the persistent stores to be searched when the fetch request is executed.

###### Usage

```swift
let store1: NSPersistentStore = ...
let store2: NSPersistenStore = ...

managedObjectContext.fetch(where: ...)
  .fromStores(store1, store2)
```

###### `NSFetchRequest` equivalent

[`affectedStores`](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506518-affectedstores)

### fetchingOnly

Specifies the key-paths to fetch.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .fetchingOnly(\.text, \.creationDate)
```

###### `NSFetchRequest` equivalent

[propertiesToFetch](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506851-propertiestofetch)

### returningDistinctResults

Specifies whether the fetch request returns only distinct values for the key-paths specified by [`fetchingOnly(_:)`](#fetchingonly).

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .fetchingOnly(\.text, \.creationDate)
  .returningDistinctResults(true)
```

###### `NSFetchRequest` equivalent

[returnsDistinctResults](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506344-returnsdistinctresults)

### groupBy

Specifies the key-paths of the properties to group the result by, when the result of the request is of type `[[String: Any]]`.

###### Usage

```swift
let result: [[String: Any]] = managedObjectContext.fetch(where: ...)
  .groupBy(\.creationDate)
```

###### `NSFetchRequest` equivalent

[propertiesToGroupBy](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506191-propertiestogroupby)

### refreshingRefetchedObjects

Specifies whether the property values of fetched objects will be updated with the current values in the persistent store.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .shouldRefreshRefetchedObjects(false)
```

###### `NSFetchRequest` equivalent

[shouldRefreshRefetchedObjects](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506440-shouldrefreshrefetchedobjects)

### having

pecifies the predicate to use to filter objects returned by a request with a [`groupBy(_:)`](#groupby) modifier applied.

###### Usage

```swift
let result: [[String: Any]] = managedObjectContext.fetch(where: ...)
  .groupBy(\.creationDate)
  .having((\Note.text).contains("Hello, World!"))
```

###### `NSFetchRequest` equivalent

[havingPredicate](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506429-havingpredicate)

### includingSubentities

Specifies whether subentities are included in the result.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .includingSubentities(true)
```

###### `NSFetchRequest` equivalent

[includesSubentities](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506366-includessubentities)

### returningObjectsAsFaults

Specifies whether objects returned from the fetch request are faults.

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .returningObjectsAsFaults(true)
```

###### `NSFetchRequest` equivalent

[returnsObjectsAsFaults](https://developer.apple.com/documentation/coredata/nsfetchrequest/1506756-returnsobjectsasfaults)

### sorted

Specifies how the objects returned by the request should be sorted. This modifier takes one required parameter and 2 optional ones:

- `by`: the key-path by which to sort the objects. (Required)
- `order`: the order in which to sort the object. (Optional, defaults to `.ascending`)
- `comparator`: a custom comparator to use to sort the objects. (Optional, defaults to `nil`)

###### Usage

```swift
managedObjectContext.fetch(where: ...)
  .sorted(by: \.text)
  .sorted(by: \.creationDate, .descending)
```

## Debugging

In `DEBUG` mode, you can inspect the actual `NSFetchRequest`s that are being executed by using the modifier `inspect(on:)` on a `FetchRequest`.

###### Example

```swift
struct Inspector: NSFetchRequestInspector {
  func inspect<Result>(_ request: NSFetchRequest<Result>) {
    // Log or print the request here.
  }
}

let notes: [Note] = try managedObjectContext
  .fetch(where: \Note.text == "Hello, World!")
  .sorted(by: \Note.creationDate, .descending)
  .inspect(on: Inspector())
  .result()
```

Happy coding! ⚡️

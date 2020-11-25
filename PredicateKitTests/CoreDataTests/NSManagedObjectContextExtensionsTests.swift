//
//  NSManagedObjectContextExtensionsTests.swift
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

final class NSManagedObjectContextExtensionsTests: XCTestCase {
  private lazy var model = NSManagedObjectModel.mergedModel(
    from: [Bundle(for: NSManagedObjectContextExtensionsTests.self)]
  )!

  private var container: NSPersistentContainer!

  override func setUp() {
    super.setUp()
    container = makePersistentContainer()
  }

  override func tearDown() {
    super.tearDown()
    container.viewContext.deleteAll(Note.self)
    container = nil
  }

  func testFetchWithBasicComparison1() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: \Note.text == "Hello, World!")
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithBasicComparison2() throws {
    let now = Date()

    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: .distantFuture, numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: .distantPast, numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: \Note.creationDate < now)
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Goodbye!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 3)
  }

  func testFetchWithBasicComparison3() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 122, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: \Note.numberOfViews >= 120)
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Goodbye!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 122)
  }

  func testFetchDictionariesWithBasicComparison() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let texts: [[String: Any]] = try container
      .viewContext
      .fetch(where: \Note.text == "Hello, World!")
      .fetchingOnly(\Note.text)
      .result()

    XCTAssertEqual(texts.count, 1)
    XCTAssertEqual(texts.first?.count, 1)
    XCTAssertEqual(texts.first?["text"] as? String, "Hello, World!")
    XCTAssertNil(texts.first?["tags"])
    XCTAssertNil(texts.first?["numberOfViews"])
    XCTAssertNil(texts.first?["creationDate"])
  }

  func testFetchAll() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetchAll()
      .result()

    XCTAssertEqual(notes.count, 2)
    XCTAssertTrue(notes.contains(where: { $0.text == "Hello, World!" }))
    XCTAssertTrue(notes.contains(where: { $0.text == "Goodbye!" }))
  }

  func testFetchWithStringComparison1() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.text).beginsWith("Hello"))
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithStringComparison2() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.text).contains("World"))
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithStringComparison3() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "7438", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.text).matches(NSRegularExpression(pattern: "[0-9]+")))
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "7438")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 3)
  }

  func testFetchWithMembershipCheck1() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.numberOfViews).between(40...100))
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithMembershipCheck2() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.text).in("Hello, World!", "Au revoir!"))
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithAndPredicate() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 125, tags: ["greeting"]),
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: []),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.text).beginsWith("Hello") && \Note.numberOfViews >= 120)
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 125)
  }

  func testFetchWithOrPredicate() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: .distantPast, numberOfViews: 3, tags: [])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.text).contains("Hello") || \Note.creationDate < Date())
      .sorted(by: \.text, .descending)
      .result()

    XCTAssertEqual(notes.count, 2)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
    XCTAssertEqual(notes.last?.text, "Goodbye!")
    XCTAssertTrue(notes.last?.tags.isEmpty ?? false)
    XCTAssertEqual(notes.last?.numberOfViews, 3)
  }

  func testFetchWithNotPredicate() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: []),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: !(\Note.text == "Hello, World!"))
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Goodbye!")
    XCTAssertEqual(notes.first?.tags, ["greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 3)
  }

  func testFetchWithPredicateOnAirstArrayElement() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting", "casual"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["casual", "greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.tags).first == "greeting")
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting", "casual"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithPredicateOnLastArrayElement() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting", "casual"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["casual", "greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.tags).last == "greeting")
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Goodbye!")
    XCTAssertEqual(notes.first?.tags, ["casual", "greeting"])
    XCTAssertEqual(notes.first?.numberOfViews, 3)
  }

  func testFetchWithPredicateOnArrayElementAtIndex() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting", "casual", "programming"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["casual", "greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.tags).at(index: 1) == "casual")
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting", "casual", "programming"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithArrayCount() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting", "casual", "programming"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["casual", "greeting"])
    )

    let notes: [Note] = try container.viewContext
      .fetch(where: (\Note.tags).count >= 3)
      .result()

    XCTAssertEqual(notes.count, 1)
    XCTAssertEqual(notes.first?.text, "Hello, World!")
    XCTAssertEqual(notes.first?.tags, ["greeting", "casual", "programming"])
    XCTAssertEqual(notes.first?.numberOfViews, 42)
  }

  func testFetchWithArraySum() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [1, 2, 3, 4, 5]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).sum == 150.0)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [10.0, 20.0, 30.0, 40.0, 50.0])
  }

  func testFetchWithArrayAverage() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [1, 2, 3, 4, 5]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).average == 3)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [1, 2, 3, 4, 5])
  }

  func testFetchWithArrayMin() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [36, 23, 120, 54, 30]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).min == 23)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [36, 23, 120, 54, 30])
  }
  
  func testFetchWithArrayMax() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [36, 23, 120, 54, 30]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).max == 120)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [36, 23, 120, 54, 30])
  }

  func testFetchWithArrayAll() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [1, 2, 3, 4, 5]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).all >= 10)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [10.0, 20.0, 30.0, 40.0, 50.0])
  }

  func testFetchWithArrayAny() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [1, 2, 3, 4, 5]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).any == 20)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [10.0, 20.0, 30.0, 40.0, 50.0])
  }

  func testFetchWithArrayNone() throws {
    try container.viewContext.insertAccounts(purchases: [
      [10.0, 20.0, 30.0, 40.0, 50.0],
      [1, 2, 3, 4, 5]
    ])

    let accounts: [Account] = try container.viewContext
      .fetch(where: (\Account.purchases).none > 5)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.purchases, [1, 2, 3, 4, 5])
  }

  func testFetchWithOneToOneRelationship1() throws {
    try container.viewContext.insertUsers(
      (name: "John Doe", billingAccountType: "Pro", purchases: [35.0, 120.0]),
      (name: "Jane Doe", billingAccountType: "Default", purchases: [])
    )

    let users: [User] = try container.viewContext
      .fetch(where: \User.billingInfo.accountType == "Pro")
      .result()

    XCTAssertEqual(users.count, 1)
    XCTAssertEqual(users.first?.name, "John Doe")
    XCTAssertEqual(users.first?.billingInfo.accountType, "Pro")
    XCTAssertEqual(users.first?.billingInfo.purchases, [35.0, 120.0])
  }

  func testFetchWithOneToOneRelationship2() throws {
    try container.viewContext.insertUsers(
      (name: "John Doe", billingAccountType: "Pro", purchases: [35.0, 120.0]),
      (name: "Jane Doe", billingAccountType: "Default", purchases: [10, 20, 30, 40, 50])
    )

    let users: [User] = try container.viewContext
      .fetch(where: (\User.billingInfo.purchases).average == 30.0)
      .result()

    XCTAssertEqual(users.count, 1)
    XCTAssertEqual(users.first?.name, "Jane Doe")
    XCTAssertEqual(users.first?.billingInfo.accountType, "Default")
    XCTAssertEqual(users.first?.billingInfo.purchases, [10, 20, 30, 40, 50])
  }

  func testFetchWithOneToManyRelationships1() throws {
    try container.viewContext.insertUserAccounts(
      (name: "Account 1", profiles: [
        (name: "John Doe", creationDate: Date()),
        (name: "Jane Doe", creationDate: Date())
      ]),
      (name: "Account 2", profiles: [
        (name: "John", creationDate: Date())
      ])
    )

    let accounts: [UserAccount] = try container.viewContext
      .fetch(where: (\UserAccount.profiles).all(\.name).contains("Doe"))
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.name, "Account 1")
    XCTAssertEqual(accounts.first?.profiles.count, 2)

    let profiles = try XCTUnwrap(accounts.first?.profiles)
    XCTAssertTrue(profiles.contains(where: { $0.name == "John Doe" }))
    XCTAssertTrue(profiles.contains(where: { $0.name == "Jane Doe" }))
  }

  func testFetchWithOneToManyRelationships2() throws {
    try container.viewContext.insertUserAccounts(
      (name: "Account 1", profiles: [
        (name: "John Doe", creationDate: Date()),
        (name: "Jane Doe", creationDate: .distantPast)
      ]),
      (name: "Account 2", profiles: [
        (name: "Jack", creationDate: Date())
      ])
    )

    let accounts: [UserAccount] = try container.viewContext
      .fetch(where: (\UserAccount.profiles).none(\.name).contains("Doe"))
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.name, "Account 2")
    XCTAssertEqual(accounts.first?.profiles.count, 1)
    XCTAssertEqual(accounts.first?.profiles.first?.name, "Jack")
  }

  func testFetchWithOneToManyRelationships3() throws {
    try container.viewContext.insertUserAccounts(
      (name: "Account 1", profiles: [
        (name: "John Doe", creationDate: Date()),
        (name: "Jane Doe", creationDate: .distantPast)
      ]),
      (name: "Account 2", profiles: [
        (name: "John", creationDate: Date())
      ])
    )

    let accounts: [UserAccount] = try container.viewContext
      .fetch(where: (\UserAccount.profiles).any(\.creationDate) == .distantPast)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.name, "Account 1")
    XCTAssertEqual(accounts.first?.profiles.count, 2)

    let profiles = try XCTUnwrap(accounts.first?.profiles)
    XCTAssertTrue(profiles.contains(where: { $0.name == "John Doe" }))
    XCTAssertTrue(profiles.contains(where: { $0.name == "Jane Doe" }))
  }

  func testFetchWithSubquery() throws {
    try container.viewContext.insertUserAccounts(
      (name: "Account 1", profiles: [
        (name: "John Doe", creationDate: Date()),
        (name: "Jane Doe", creationDate: .distantPast)
      ]),
      (name: "Account 2", profiles: [
        (name: "John Doe", creationDate: Date()),
        (name: "Jane Doe", creationDate: .distantPast),
        (name: "Jack Doe", creationDate: .distantFuture)
      ])
    )
  
    let accounts: [UserAccount] = try container.viewContext
      .fetch(where: (\UserAccount.name).contains("Account") && all(\.profiles, where: (\Profile.name).contains("Doe")).size == 2)
      .result()

    XCTAssertEqual(accounts.count, 1)
    XCTAssertEqual(accounts.first?.name, "Account 1")
    XCTAssertEqual(accounts.first?.profiles.count, 2)

    let profiles = try XCTUnwrap(accounts.first?.profiles)
    XCTAssertTrue(profiles.contains(where: { $0.name == "John Doe" }))
    XCTAssertTrue(profiles.contains(where: { $0.name == "Jane Doe" }))
  }

  func testCount() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let count = try container.viewContext.count(where: \Note.text == "Hello, World!")

    XCTAssertEqual(count, 1)
  }

  func testCountAll() throws {
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: Date(), numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: Date(), numberOfViews: 3, tags: ["greeting"])
    )

    let count = try container.viewContext.countAll(Note.self)

    XCTAssertEqual(count, 2)
  }
  
  func testFetchedResultsController() throws {
    let now = Date()
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: .distantPast, numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: now, numberOfViews: 23, tags: ["greeting"]),
      (text: "Not dead yet!", creationDate: now, numberOfViews: 18, tags: ["greeting"]),
      (text: "Goodbye again!", creationDate: .distantFuture, numberOfViews: 3, tags: ["greeting"])
    )
    
    let controller = container.viewContext
      .fetch(where: \Note.creationDate == now)
      .fetchedResultsController()
    
    try controller.performFetch()
    let sectionCount = controller.sections?.count
    let itemCount = controller.sections?.first?.numberOfObjects
    
    XCTAssertEqual(sectionCount, 1)
    XCTAssertEqual(itemCount, 2)
  }
  
  func testFetchedResultsControllerSections() throws {
    let now = Date()
    try container.viewContext.insertNotes(
      (text: "Hello, World!", creationDate: .distantPast, numberOfViews: 42, tags: ["greeting"]),
      (text: "Goodbye!", creationDate: now, numberOfViews: 23, tags: ["greeting"]),
      (text: "Not dead yet!", creationDate: now, numberOfViews: 18, tags: ["greeting"]),
      (text: "Goodbye again!", creationDate: .distantFuture, numberOfViews: 3, tags: ["greeting"])
    )
    
    let controller = container.viewContext
      .fetchAll()
      .sorted(by: \Note.creationDate)
      .fetchedResultsController(sectionNameKeyPath: \Note.creationDate)
    
    try controller.performFetch()
    
    let sectionCount = controller.sections?.count
    XCTAssertEqual(sectionCount, 3)
    
    let itemCount0 = controller.sections?[0].numberOfObjects
    let itemCount1 = controller.sections?[1].numberOfObjects
    let itemCount2 = controller.sections?[2].numberOfObjects
    
    XCTAssertEqual(itemCount0, 1)
    XCTAssertEqual(itemCount1, 2)
    XCTAssertEqual(itemCount2, 1)
  }

  func testNSFetchRequestsAreForwardedToInspector() throws {
    let inspector = MockNSFetchRequestInspector()

    let _: [Note] = try container.viewContext
      .fetchAll()
      .inspect(on: inspector)
      .result()

    XCTAssertTrue(inspector.inspectCalled)
  }

  private func makePersistentContainer() -> NSPersistentContainer {
    return self.makePersistentContainer(with: model)
  }
}

// MARK: - Managed Objects

class Note: NSManagedObject {
  @NSManaged var text: String
  @NSManaged var creationDate: Date
  @NSManaged var numberOfViews: Int
  @NSManaged var tags: [String]
}

class Account: NSManagedObject {
  @NSManaged var purchases: [Double]
}

class User: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var billingInfo: BillingInfo
}

class BillingInfo: NSManagedObject {
  @NSManaged var accountType: String
  @NSManaged var purchases: [Double]
}

class UserAccount: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var profiles: Set<Profile>
}

class Profile: NSManagedObject {
  @NSManaged var name: String
  @NSManaged var creationDate: Date
}

// MARK: -

private extension XCTestCase {
  func makePersistentContainer(with model: NSManagedObjectModel) -> NSPersistentContainer {
    let expectation = self.expectation(description: "container")
    let description = NSPersistentStoreDescription()
    description.type = NSInMemoryStoreType

    let container = NSPersistentContainer(name: "DataModel", managedObjectModel: model)
    container.persistentStoreDescriptions = [description]
    container.loadPersistentStores { description, error in
      if let error = error as NSError? {
        fatalError("\(error), \(error.userInfo)")
      }

       expectation.fulfill()
    }

    wait(for: [expectation], timeout: 5)
    return container
  }
}

private extension NSManagedObjectContext {
  func insertNotes(_ notes: (text: String, creationDate: Date, numberOfViews: Int, tags: [String])...) throws {
    for description in notes {
      let note = NSEntityDescription.insertNewObject(forEntityName: "Note", into: self) as! Note
      note.text = description.text
      note.tags = description.tags
      note.numberOfViews = description.numberOfViews
      note.creationDate = description.creationDate
    }
    
    try save()
  }

  func insertAccounts(purchases: [[Double]]) throws {
    for description in purchases {
      let account = NSEntityDescription.insertNewObject(forEntityName: "Account", into: self) as! Account
      account.purchases = description
    }
    
    try save()
  }

  func insertUsers(_ users: (name: String, billingAccountType: String, purchases: [Double])...) throws {
    for description in users {
      let user = NSEntityDescription.insertNewObject(forEntityName: "User", into: self) as! User
      user.name = description.name
      user.billingInfo = NSEntityDescription.insertNewObject(forEntityName: "BillingInfo", into: self) as! BillingInfo
      user.billingInfo.accountType = description.billingAccountType
      user.billingInfo.purchases = description.purchases
    }

    try save()
  }

  func insertUserAccounts(_ accounts: (name: String, profiles: [(name: String, creationDate: Date)])...) throws {
    for description in accounts {
      let account = NSEntityDescription.insertNewObject(forEntityName: "UserAccount", into: self) as! UserAccount
      account.name = description.name
      var profiles: [Profile] = []
      account.profiles = Set()
      
      for profileDescription in description.profiles {
        let profile = NSEntityDescription.insertNewObject(forEntityName: "Profile", into: self) as! Profile
        profile.name = profileDescription.name
        profile.creationDate = profileDescription.creationDate
        profiles.append(profile)
      }

      account.profiles = Set(profiles)
    }

    try save()
  }

  func deleteAll<T: NSManagedObject>(_ type: T.Type) {
    let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
    fetchRequest.includesPropertyValues = false
    
    do {
      let items = try fetch(fetchRequest)
      
      for item in items {
        delete(item)
      }
      
      try save()
    } catch {
    }
  }
}

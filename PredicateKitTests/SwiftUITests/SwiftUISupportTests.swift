//
//  SwiftUISupportTests.swift
//  PredicateKitTests
//
//  Copyright 2021 Faiçal Tchirou
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
import SwiftUI
#if canImport(UIKit)
import UIKit
#endif
import XCTest

@testable import PredicateKit

// Basic tests to ensure that predicates and fetch requests passed to SwiftUI's `FetchRequest` end up in the
// view's graph. We don't really test here that our `Predicate`s and `FetchRequest`s are properly converted to
// `NSPredicate`s and `NSFetchRequest`s; we rely on the tests in `NSFetchRequestBuilderTests` and assume the conversion
// correctness. Here, we just want to ensure that the view's graph will contain the expected `NSFetchRequest`.
@available(iOS 15.0, watchOS 8.0, tvOS 15.0, macOS 12.0, *)
class SwiftUISupportTests: XCTestCase {
  func testFetchRequestPropertyWrapperWithBasicPredicate() throws {
    struct ContentView: View {
      @SwiftUI.FetchRequest(predicate: \Note.text == "Hello, World!")
      var notes: FetchedResults<Note>

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }
      }
    }

    let view = ContentView().environment(\.managedObjectContext, .default)
    let request = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes") as? SwiftUI.FetchRequest<Note>
    )

    let comparison = try XCTUnwrap(request.projectedValue.wrappedValue.nsPredicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testFetchRequestPropertyWrapperWithPredicateAndSortDescriptors() throws {
    struct ContentView: View {
      @SwiftUI.FetchRequest(
        fetchRequest: FetchRequest(predicate: \Note.creationDate < .now)
          .sorted(by: \.text, .ascending)
          .sorted(by: \.creationDate, .descending)
      )
      var notes: FetchedResults<Note>

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }
      }
    }

    let view = ContentView().environment(\.managedObjectContext, .default)
    let request = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes") as? SwiftUI.FetchRequest<Note>
    )

    let comparison = try XCTUnwrap(request.projectedValue.wrappedValue.nsPredicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "creationDate"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: Date.now))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)

    let sortDescriptors = try XCTUnwrap(request.projectedValue.wrappedValue.nsSortDescriptors)
    XCTAssertEqual(sortDescriptors.count, 2)
    XCTAssertEqual(sortDescriptors.first?.key, "text")
    XCTAssertTrue(sortDescriptors.first?.ascending ?? false)
    XCTAssertEqual(sortDescriptors.last?.key, "creationDate")
    XCTAssertFalse(sortDescriptors.last?.ascending ?? true)
  }

  func testFetchRequestPropertyWrapperWithBasicModifier() throws {
    struct ContentView: View {
      @SwiftUI.FetchRequest(
        fetchRequest: FetchRequest(predicate: \Note.creationDate < .now)
          .limit(100)
      )
      var notes: FetchedResults<Note>

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }
      }
    }

    let view = ContentView().environment(\.managedObjectContext, .default)
    let request = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes") as? SwiftUI.FetchRequest<Note>
    )

    let comparison = try XCTUnwrap(request.projectedValue.wrappedValue.nsPredicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "creationDate"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: Date.now))
    XCTAssertEqual(comparison.predicateOperatorType, .lessThan)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
    // TODO: Find a way to assert that the fetch limit is indeed 100.
  }

  func testFetchRequestPropertyWrapperWithAnimation() throws {
    struct ContentView: View {
      @SwiftUI.FetchRequest(predicate: \Note.numberOfViews == 42, animation: .easeIn)
      var notes: FetchedResults<Note>

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }
      }
    }

    let view = ContentView().environment(\.managedObjectContext, .default)
    let request = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes") as? SwiftUI.FetchRequest<Note>
    )

    let transaction = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes", "transaction") as? Transaction
    )
    XCTAssertEqual(transaction.animation, .easeIn)

    let comparison = try XCTUnwrap(request.projectedValue.wrappedValue.nsPredicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "numberOfViews"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: 42))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testFetchRequestPropertyWrapperWithTransaction() throws {
    struct ContentView: View {
      @SwiftUI.FetchRequest(
        fetchRequest: FetchRequest(predicate: \Note.text == "Hello, World!"),
        transaction: .nonContinuousEaseInOut
      )
      var notes: FetchedResults<Note>

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }
      }
    }

    let view = ContentView().environment(\.managedObjectContext, .default)
    let request = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes") as? SwiftUI.FetchRequest<Note>
    )

    let transaction = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes", "transaction") as? Transaction
    )
    XCTAssertEqual(transaction.animation, .easeInOut)
    XCTAssertFalse(transaction.isContinuous)

    let comparison = try XCTUnwrap(request.projectedValue.wrappedValue.nsPredicate as? NSComparisonPredicate)
    XCTAssertEqual(comparison.leftExpression, NSExpression(forKeyPath: "text"))
    XCTAssertEqual(comparison.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
    XCTAssertEqual(comparison.predicateOperatorType, .equalTo)
    XCTAssertEqual(comparison.comparisonPredicateModifier, .direct)
  }

  func testFetchRequestPropertyWrapperWithNoPredicate() throws {
    struct ContentView: View {
      @SwiftUI.FetchRequest(
        fetchRequest: FetchRequest()
          .sorted(by: \.text, .ascending)
      )
      var notes: FetchedResults<Note>

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }
      }
    }

    let view = ContentView().environment(\.managedObjectContext, .default)
    let request = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_notes") as? SwiftUI.FetchRequest<Note>
    )

    XCTAssertEqual(request.projectedValue.wrappedValue.nsPredicate, NSPredicate(value: true))
  }
  
  #if canImport(UIKit) && !canImport(WatchKit)
  func testFetchRequestPropertyWrapperWithChangingPredicate() throws {
    let expectation = self.expectation(description: "assertions complete successfully")

    struct ContentView: View {
      @SwiftUI.FetchRequest(fetchRequest: FetchRequest())
      var notes: FetchedResults<Note>

      private let completion: () -> Void

      init(completion: @escaping () -> Void) {
        self.completion = completion
      }

      var body: some View {
        List(notes, id: \.self) {
          Text($0.text)
        }.onAppear {
          notes.updatePredicate(\Note.text == "Hello, World!")

          let comparison = notes.nsPredicate as? NSComparisonPredicate
          XCTAssertEqual(comparison?.leftExpression, NSExpression(forKeyPath: "text"))
          XCTAssertEqual(comparison?.rightExpression, NSExpression(forConstantValue: "Hello, World!"))
          XCTAssertEqual(comparison?.predicateOperatorType, .equalTo)
          XCTAssertEqual(comparison?.comparisonPredicateModifier, .direct)

          completion()
        }
      }
    }

    let view = ContentView { expectation.fulfill() }
      .environment(\.managedObjectContext, testContainer().viewContext)
    let window = UIWindow(frame: .zero)

    // Trick the system into installing the view in a "view hierarchy" so we can
    // access any underlying @StateObject without crashing.
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()

    wait(for: [expectation], timeout: 5)
  }

  func testSectionedFetchRequestPropertyWrapperWithNoPredicate() throws {
    let expectation = self.expectation(description: "assertions complete successfully")

    struct ContentView: View {
      @SwiftUI.SectionedFetchRequest(
        fetchRequest: FetchRequest()
          .sorted(by: \.billingInfo.accountType, .ascending)
          .sorted(by: \.name, .ascending),
        sectionIdentifier: \.billingInfo.accountType
      )
      var users: SectionedFetchResults<String, User>

      private let completion: () -> Void

      init(completion: @escaping () -> Void) {
        self.completion = completion
      }

      var body: some View {
        List(users, id: \.id) { section in
          Section(section.id) {
            ForEach(section, id: \.objectID) { user in
              Text(user.name)
            }
          }
        }.onAppear {
          XCTAssertEqual(users.sectionIdentifier, \.billingInfo.accountType)
          XCTAssertEqual(users.nsPredicate, NSPredicate(value: true))
          completion()
        }
      }
    }

    let view = ContentView { expectation.fulfill() }
      .environment(\.managedObjectContext, testContainer().viewContext)
    let window = UIWindow(frame: .zero)
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()

    wait(for: [expectation], timeout: 5)
  }

  func testSectionedFetchRequestPropertyWrapperWithAnimationAndNoPredicate() throws {
    let expectation = self.expectation(description: "assertions complete successfully")

    struct ContentView: View {
      @SwiftUI.SectionedFetchRequest(
        fetchRequest: FetchRequest()
          .sorted(by: \.billingInfo.accountType, .ascending)
          .sorted(by: \.name, .ascending),
        sectionIdentifier: \.billingInfo.accountType,
        animation: .easeIn
      )
      var users: SectionedFetchResults<String, User>

      private let completion: () -> Void

      init(completion: @escaping () -> Void) {
        self.completion = completion
      }

      var body: some View {
        List(users, id: \.id) { section in
          Section(section.id) {
            ForEach(section, id: \.objectID) { user in
              Text(user.name)
            }
          }
        }.onAppear {
          XCTAssertEqual(users.nsPredicate, NSPredicate(value: true))
          completion()
        }
      }
    }

    let view = ContentView { expectation.fulfill() }
      .environment(\.managedObjectContext, testContainer().viewContext)
    let window = UIWindow(frame: .zero)
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()

    wait(for: [expectation], timeout: 5)

    let transaction = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_users", "transaction") as? Transaction
    )

    XCTAssertEqual(transaction.animation, .easeIn)
  }

  func testSectionedFetchRequestPropertyWrapperWithTransactionAndNoPredicate() throws {
    let expectation = self.expectation(description: "assertions complete successfully")

    struct ContentView: View {
      @SwiftUI.SectionedFetchRequest(
        fetchRequest: FetchRequest()
          .sorted(by: \.billingInfo.accountType, .ascending)
          .sorted(by: \.name, .ascending),
        sectionIdentifier: \.billingInfo.accountType,
        transaction: .nonContinuousEaseInOut
      )
      var users: SectionedFetchResults<String, User>

      private let completion: () -> Void

      init(completion: @escaping () -> Void) {
        self.completion = completion
      }

      var body: some View {
        List(users, id: \.id) { section in
          Section(section.id) {
            ForEach(section, id: \.objectID) { user in
              Text(user.name)
            }
          }
        }.onAppear {
          XCTAssertEqual(users.nsPredicate, NSPredicate(value: true))
          completion()
        }
      }
    }

    let view = ContentView { expectation.fulfill() }
      .environment(\.managedObjectContext, testContainer().viewContext)
    let window = UIWindow(frame: .zero)
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()

    wait(for: [expectation], timeout: 5)

    let transaction = try XCTUnwrap(
      Mirror(reflecting: view).descendant("content", "_users", "transaction") as? Transaction
    )

    XCTAssertEqual(transaction.animation, .easeInOut)
    XCTAssertFalse(transaction.isContinuous)
  }

  func testSectionedFetchRequestPropertyWrapperWithBasicPredicate() throws {
    let expectation = self.expectation(description: "assertions complete successfully")

    struct ContentView: View {
      @SwiftUI.SectionedFetchRequest(
        fetchRequest: FetchRequest(predicate: \User.name == "John Doe"),
        sectionIdentifier: \.billingInfo.accountType
      )
      var users: SectionedFetchResults<String, User>

      private let completion: () -> Void

      init(completion: @escaping () -> Void) {
        self.completion = completion
      }

      var body: some View {
        List(users, id: \.id) { section in
          Section(section.id) {
            ForEach(section, id: \.objectID) { user in
              Text(user.name)
            }
          }
        }.onAppear {
          let comparison = users.nsPredicate as? NSComparisonPredicate
          XCTAssertEqual(comparison?.leftExpression, NSExpression(forKeyPath: "name"))
          XCTAssertEqual(comparison?.rightExpression, NSExpression(forConstantValue: "John Doe"))
          XCTAssertEqual(comparison?.predicateOperatorType, .equalTo)
          XCTAssertEqual(comparison?.comparisonPredicateModifier, .direct)

          completion()
        }
      }
    }

    let view = ContentView { expectation.fulfill() }
      .environment(\.managedObjectContext, testContainer().viewContext)
    let window = UIWindow(frame: .zero)
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()

    wait(for: [expectation], timeout: 5)
  }

  func testSectionedFetchRequestPropertyWrapperWithChangingPredicate() throws {
    let expectation = self.expectation(description: "assertions complete successfully")

    struct ContentView: View {
      @SwiftUI.SectionedFetchRequest(
        fetchRequest: FetchRequest(predicate: \User.name == "John Doe"),
        sectionIdentifier: \.billingInfo.accountType
      )
      var users: SectionedFetchResults<String, User>

      private let completion: () -> Void

      init(completion: @escaping () -> Void) {
        self.completion = completion
      }

      var body: some View {
        List(users, id: \.id) { section in
          Section(section.id) {
            ForEach(section, id: \.objectID) { user in
              Text(user.name)
            }
          }
        }.onAppear {
          users.updatePredicate(\User.billingInfo.accountType == "test")

          let comparison = users.nsPredicate as? NSComparisonPredicate
          XCTAssertEqual(comparison?.leftExpression, NSExpression(forKeyPath: "billingInfo.accountType"))
          XCTAssertEqual(comparison?.rightExpression, NSExpression(forConstantValue: "test"))
          XCTAssertEqual(comparison?.predicateOperatorType, .equalTo)
          XCTAssertEqual(comparison?.comparisonPredicateModifier, .direct)

          completion()
        }
      }
    }

    let view = ContentView { expectation.fulfill() }
      .environment(\.managedObjectContext, testContainer().viewContext)
    let window = UIWindow(frame: .zero)
    window.rootViewController = UIHostingController(rootView: view)
    window.makeKeyAndVisible()

    wait(for: [expectation], timeout: 5)
  }
  #endif

  private func testContainer() -> NSPersistentContainer {
    let model = NSManagedObjectModel.mergedModel(from: [Bundle(for: SwiftUISupportTests.self)])!
    return makePersistentContainer(with: model)
  }
}

// MARK: -

private extension NSManagedObjectContext {
  static let `default` = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
}

private extension Date {
  static let now = Date()
}

@available(iOS 13.0, watchOS 6.0, tvOS 13.0, *)
private extension Transaction {
  static var nonContinuousEaseInOut: Transaction = {
    var transaction = Transaction(animation: .easeInOut)
    transaction.isContinuous = false
    return transaction
  }()
}

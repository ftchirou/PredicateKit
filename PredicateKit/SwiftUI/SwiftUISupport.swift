//
//  SwiftUISupport.swift
//  PredicateKit
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
import SwiftUI

@available(iOS 13.0, *)
extension SwiftUI.FetchRequest where Result: NSManagedObject {
  /// Creates an instance by defining a fetch request based on the provided predicate and animation.
  ///
  /// - Parameter predicate: The predicate used to define a filter for the fetched results.
  /// - Parameter animation: The animation used for any changes to the fetched results.
  ///
  /// ## Example
  ///
  ///     struct ContentView: View {
  ///       @SwiftUI.FetchRequest(predicate: \Note.text == "Hello, World!")
  ///       var notes: FetchedResults<Note>
  ///
  ///       var body: some View {
  ///         List(notes, id: \.self) {
  ///           Text($0.text)
  ///         }
  ///       }
  ///
  public init(predicate: Predicate<Result>, animation: Animation? = nil) {
    self.init(fetchRequest: FetchRequest(predicate: predicate), animation: animation)
  }

  /// Creates an instance from the provided fetch request and animation.
  ///
  /// - Parameter fetchRequest: The request used to produce the fetched results.
  /// - Parameter animation: The animation used for any changes to the fetched results.
  ///
  /// ## Example
  ///
  ///     struct ContentView: View {
  ///       @SwiftUI.FetchRequest(
  ///         fetchRequest: FetchRequest(predicate: (\Note.text).contains("Hello, World!"))
  ///           .limit(50)
  ///           .offset(100)
  ///           .sorted(by: \.Note.creationDate)
  ///       )
  ///       var notes: FetchedResults<Note>
  ///
  ///       var body: some View {
  ///         List(notes, id: \.self) {
  ///           Text($0.text)
  ///         }
  ///       }
  ///
  public init(fetchRequest: FetchRequest<Result>, animation: Animation? = nil) {
    let entityName = Result.entity().name ?? String(describing: Result.self)
    let fetchRequestBuilder = NSFetchRequestBuilder(entityName: entityName)
    self.init(fetchRequest: fetchRequestBuilder.makeRequest(from: fetchRequest), animation: animation)
  }

  /// Creates an instance from the provided fetch request and transaction.
  ///
  /// - Parameter fetchRequest: The request used to produce the fetched results.
  /// - Parameter transaction: The transaction used for any changes to the fetched results.
  ///
  /// ## Example
  ///
  ///      struct ContentView: View {
  ///        @SwiftUI.FetchRequest(
  ///          fetchRequest: FetchRequest(predicate: \Note.text == "Hello, World!")),
  ///          transaction: Transaction(animation: .easeIn)
  ///        )
  ///        var notes: FetchedResults<Note>
  ///
  ///        var body: some View {
  ///          List(notes, id: \.self) {
  ///            Text($0.text)
  ///          }
  ///        }
  ///      }
  ///
  public init(fetchRequest: FetchRequest<Result>, transaction: Transaction) {
    let entityName = Result.entity().name ?? String(describing: Result.self)
    let fetchRequestBuilder = NSFetchRequestBuilder(entityName: entityName)
    self.init(fetchRequest: fetchRequestBuilder.makeRequest(from: fetchRequest), transaction: transaction)
  }
}

@available(iOS 13.0, *)
extension FetchRequest {
  /// Creates a fetch request using the provided predicate.
  ///
  /// - Parameter predicate: The predicate used to define a filter for the fetched results.
  ///
  /// - Important: Use this initializer **only** in conjunction with the SwiftUI property wrapper` @FetchRequest`. Fetch
  ///   requests created with this initializer cannot be executed outside of SwiftUI as they rely on the CoreData
  ///   managed object context injected in the environment of a SwiftUI view.
  ///
  /// ## Example
  ///
  ///       struct ContentView: View {
  ///        @SwiftUI.FetchRequest(
  ///          fetchRequest: FetchRequest(predicate: (\Note.text).contains("Hello, World!"))
  ///            .sorted(by: \Note.creationDate, .ascending)
  ///            .limit(100)
  ///        )
  ///        var notes: FetchedResults<Note>
  ///
  ///        var body: some View {
  ///          List(notes, id: \.self) {
  ///            Text($0.text)
  ///          }
  ///        }
  ///      }
  ///
  public init(predicate: Predicate<Entity>) {
    let context = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    self.init(context: context, predicate: predicate)
  }
}

//
//  NSFetchRequestInspector.swift
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

/// Represents an object used to inspect at runtime the underlying `NSFetchRequest`s generated from objects of type
/// `FetchRequest`.
///
public protocol NSFetchRequestInspector {
  /// Inspects, however fit (e.g. logs, prints, etc.), an `NSFetchRequest` generated from an object of type
  /// `FetchRequest`.
  ///
  /// - Note: The `request` parameter is read-only. Modifying it has no effect on the request ultimately
  ///   executed by a `NSManagedObjectContext`.
  ///
  func inspect<Result>(_ request: NSFetchRequest<Result>)
}

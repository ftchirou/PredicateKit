//
//  MockNSFetchRequestInspector.swift
//  PredicateKitTests
//
//  Created by Faiçal Tchirou on 30.10.20.
//

import CoreData
import Foundation

@testable import PredicateKit

final class MockNSFetchRequestInspector: NSFetchRequestInspector {
  var inspectCalled = false
  
  init() {
  }

  func inspect<Result: NSFetchRequestResult>(_ request: NSFetchRequest<Result>) {
    inspectCalled = true
  }
}

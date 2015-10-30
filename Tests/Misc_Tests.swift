//
//  VKTests.swift
//  VKTests
//
//  Created by Алексей Кудрявцев on 18.04.15.
//  Copyright (c) 2015 Алексей Кудрявцев. All rights reserved.
//

import XCTest
@testable import SwiftyVK


class Misc_Tests: XCTestCase {

  
  
  func test_language() {
    print("\n\nLocales \(NSLocale.preferredLanguages())")
    
    if let lang = VK.defaults.language {
      print("SwiftyVK language is \"" + lang + "\"\n")
    }
    else {
      XCTFail("Language not set")
    }
  }
}

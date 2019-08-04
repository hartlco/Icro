//
//  Created by Martin Hartl on 04.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit
import XCTest
@testable import Icro
@testable import IcroKit

class HTTPMethodTests: XCTestCase {
    func test_method_isCorrectForGet() {
        XCTAssert(HttpMethod.get.method == "GET")
    }

    func test_method_isCorrectForPost() {
        XCTAssert(HttpMethod.post(nil).method == "POST")
    }

    func test_method_isCorrectForDelete() {
        XCTAssert(HttpMethod.delete.method == "DELETE")
    }
}

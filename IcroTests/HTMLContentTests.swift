//
//  Created by martin on 18.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import XCTest
@testable import Icro
@testable import IcroKit

class HTMLContentTests: XCTestCase {
    func test_imagesLinks_fromHTMLContent() {
        // swiftlint:disable line_length
        let htmlString = "<!DOCTYPE html><html lang=\"en\"><body><p><img src=\"http://share.hartl.co/micro/A948A912-8D59-4131-BD7C-F0AF10944808.jpg\"/><img src=\"http://share.hartl.co/micro/2302C8AE-5672-450C-8A16-B365048B7412.jpg\"/><img src=\"http://share.hartl.co/micro/37C4E25F-FA48-48B4-BBEC-A64509D010E1.jpg\"/></p></body></html>"
        let htmlContent = HTMLContent(rawHTMLString: htmlString, itemID: "1")
        let expectedURLStrings = ["http://share.hartl.co/micro/A948A912-8D59-4131-BD7C-F0AF10944808.jpg",
                                  "http://share.hartl.co/micro/2302C8AE-5672-450C-8A16-B365048B7412.jpg",
                                  "http://share.hartl.co/micro/37C4E25F-FA48-48B4-BBEC-A64509D010E1.jpg"
                                  ].compactMap(URL.init)
        XCTAssert(expectedURLStrings == htmlContent.imageLinks, "Parsed images links no equal")
    }

    func test_videoLinks_fromHTMLContent() {
        // swiftlint:disable line_length
        let htmlString = "<!DOCTYPE html><html lang=\"en\"><body><p><video src=\"http://share.hartl.co/micro/A948A912-8D59-4131-BD7C-F0AF10944808.mp4\"/><video src=\"http://share.hartl.co/micro/2302C8AE-5672-450C-8A16-B365048B7412.mp4\"/><video src=\"http://share.hartl.co/micro/37C4E25F-FA48-48B4-BBEC-A64509D010E1.mp4\"/></p></body></html>"
        let htmlContent = HTMLContent(rawHTMLString: htmlString, itemID: "1")
        let expectedURLStrings = ["http://share.hartl.co/micro/A948A912-8D59-4131-BD7C-F0AF10944808.mp4",
                                  "http://share.hartl.co/micro/2302C8AE-5672-450C-8A16-B365048B7412.mp4",
                                  "http://share.hartl.co/micro/37C4E25F-FA48-48B4-BBEC-A64509D010E1.mp4"
            ].compactMap(URL.init)
        XCTAssert(expectedURLStrings == htmlContent.videoLinks, "Parsed images links no equal")
    }

    func test_attributedStringWihthoutImages_hasCorrectText() {
        // swiftlint:disable line_length
        let htmlString = "<!DOCTYPE html><html lang=\"en\"><body><h1>Hi thats a test</h1><p><img src=\"http://share.hartl.co/micro/A948A912-8D59-4131-BD7C-F0AF10944808.jpg\"/><img src=\"http://share.hartl.co/micro/2302C8AE-5672-450C-8A16-B365048B7412.jpg\"/><img src=\"http://share.hartl.co/micro/37C4E25F-FA48-48B4-BBEC-A64509D010E1.jpg\"/></p></body></html>"
        let htmlContent = HTMLContent(rawHTMLString: htmlString, itemID: "1")
        XCTAssert(htmlContent.attributedStringWithoutImages()?.string == "Hi thats a test",
                  "String not correctly parsed")
    }
}

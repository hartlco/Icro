//
//  Created by martin on 11.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

public struct Font {
    public init() { }

    public var body: UIFont {
        let font = UIFont.systemFont(ofSize: 16)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var boldBody: UIFont {
        let font = UIFont.boldSystemFont(ofSize: 16)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var italicBody: UIFont {
        let font = UIFont.italicSystemFont(ofSize: 16)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var name: UIFont {
        let font = UIFont.systemFont(ofSize: 17, weight: .medium)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var username: UIFont {
        let font = UIFont.systemFont(ofSize: 13)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var time: UIFont {
        let font = UIFont.systemFont(ofSize: 11)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var loading: UIFont {
        let font = UIFont.boldSystemFont(ofSize: 15)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }
}

//
//  Created by martin on 11.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias XFont = UIFont
#elseif os(OSX)
public typealias XFont = NSFont
#endif

public struct Font {
    public init() { }

    public var body: XFont {
        let font = XFont.systemFont(ofSize: 16)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var boldBody: XFont {
        let font = XFont.boldSystemFont(ofSize: 16)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var italicBody: XFont {
        let font = XFont.italicSystemFont(ofSize: 16)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var name: XFont {
        let font = XFont.systemFont(ofSize: 17, weight: .medium)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var username: XFont {
        let font = XFont.systemFont(ofSize: 13)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var time: XFont {
        let font = XFont.systemFont(ofSize: 11)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var loading: XFont {
        let font = XFont.boldSystemFont(ofSize: 15)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }
}

#if os(OSX)
extension NSFont {
    class func italicSystemFont(ofSize size: CGFloat) -> NSFont {
        return NSFont.systemFont(ofSize: size)
    }
}

class UIFontMetrics {
    enum TextStyle {
        case body
        case headline
    }

    init(forTextStyle textStyle: TextStyle) { }

    func scaledFont(for font: XFont) -> XFont {
        return font
    }
}
#endif

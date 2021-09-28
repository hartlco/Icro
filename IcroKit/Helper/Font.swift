//
//  Created by martin on 11.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Settings

#if os(iOS)
import UIKit
public typealias XFont = UIFont
#elseif os(OSX)
public typealias XFont = NSFont
#endif

public struct Font {
    private let userSettings: UserSettings

    public init(userSettings: UserSettings = .shared) {
        self.userSettings = userSettings
    }

    #if os(iOS)
    let bodySize = 17.0
    #elseif os(OSX)
    let bodySize = 13.0
    #endif

    public var body: XFont {
        let useMedium = userSettings.useMediumContentFont
        let font = XFont.systemFont(ofSize: bodySize,
                                    weight: useMedium ? .medium : .regular)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var boldBody: XFont {
        let font = XFont.boldSystemFont(ofSize: bodySize)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)
        return fontMetrics.scaledFont(for: font)
    }

    public var italicBody: XFont {
        let font = body
        let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)
        let fontMetrics = UIFontMetrics(forTextStyle: .body)

        if let descriptor = descriptor {
            return fontMetrics.scaledFont(for: UIFont(descriptor: descriptor, size: bodySize))
        } else {
            return font
        }
    }

    public var name: XFont {
        let font = XFont.systemFont(ofSize: 19, weight: .bold)
        let fontMetrics = UIFontMetrics(forTextStyle: .headline)
        return fontMetrics.scaledFont(for: font)
    }

    public var username: XFont {
        let font = XFont.systemFont(ofSize: 14, weight: .medium)
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

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

import SwiftUI

public struct Font {
    private let stylePreference: StylePreference

    public init(stylePreference: StylePreference) {
        self.stylePreference = stylePreference
    }

    #if os(iOS)
    let bodySize = 17.0
    #elseif os(OSX)
    let bodySize = 13.0
    #endif

    public var body: XFont {
        let font = XFont.systemFont(ofSize: bodySize,
                                    weight: stylePreference.useMediumContent ? .medium : .regular)
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

//
//  Created by Martin Hartl on 27.12.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import Sourceful
import IcroKit
import Style
import Settings

final class IcroEditorTheme: SourceCodeTheme {
    var lineNumbersStyle: LineNumbersStyle? {
        return nil
    }

    var gutterStyle: GutterStyle = GutterStyle(backgroundColor: Color.black, minimumWidth: 0)

    var font: Sourceful.Font {
        Style.Font().body
    }

    var backgroundColor: Sourceful.Color {
        Color.backgroundColor
    }

    func attributes(for token: Token) -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()

        if let token = token as? SimpleSourceCodeToken {
            attributes[.foregroundColor] = color(for: token.type)

            switch token.type {
            case .string:
                let descriptor = font.fontDescriptor.withSymbolicTraits(.traitBold)!
                attributes[.font] = UIFont(descriptor: descriptor, size: font.pointSize)
            case .identifier:
                let descriptor = font.fontDescriptor.withSymbolicTraits(.traitItalic)!
                attributes[.font] = UIFont(descriptor: descriptor, size: font.pointSize)
            default:
                break
            }

            attributes[.foregroundColor] = color(for: token.type)
        }

        return attributes
    }

    public func globalAttributes() -> [NSAttributedString.Key: Any] {
        var attributes = [NSAttributedString.Key: Any]()

        attributes[.font] = font
        attributes[.foregroundColor] = Color.textColor

        return attributes
    }

    func color(for syntaxColorType: SourceCodeTokenType) -> Sourceful.Color {
        switch syntaxColorType {
        case .plain:
            return Color.textColor
        case .string, .identifier, .keyword, .comment:
            return Color.secondaryTextColor
        case .editorPlaceholder, .number:
            return Color.main
        }
    }
}

//
//  Created by martin on 15.08.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

#if os(iOS)
import UIKit
public typealias XColor = UIColor
#elseif os(OSX)
public typealias XColor = NSColor
#endif

public struct Color {
    public static let main = XColor(named: "main")!
    public static var accentLight: XColor {
        return Theme.colorTheme.accentLightColor
    }
    public static var accentSuperLight: XColor {
        return Theme.colorTheme.accentSuperLightColor
    }
    public static let accent = XColor(named: "accent")!
    public static let yellow = XColor(named: "yellow")
    public static let accentDark = XColor(named: "accentDark")!
    public static let separatorColor = XColor(named: "separatorColor")!

    public static var backgroundColor: XColor {
        return Theme.colorTheme.backgroundColor
    }

    public static var textColor: XColor {
        return Theme.colorTheme.textColor
    }

    public static var secondaryTextColor: XColor {
        return Theme.colorTheme.secondaryTextColor
    }

    public static var buttonColor: XColor {
        return Theme.colorTheme.buttonColor
    }
}

public enum Theme {
    case light
    case gray
    case black

    public static let currentTheme = Theme.black

    public static var colorTheme: ColorTheme.Type {
        switch currentTheme {
        case .black:
            return BlackTheme.self
        case .gray:
            return GrayTheme.self
        case .light:
            return LightTheme.self
        }
    }
}

public protocol ColorTheme {
    static var textColor: XColor { get }
    static var secondaryTextColor: XColor { get }
    static var backgroundColor: XColor { get }
    static var buttonColor: XColor { get }
    static var accentLightColor: XColor { get }
    static var accentSuperLightColor: XColor { get }
    static var separatorColor: XColor { get }
}

struct BlackTheme: ColorTheme {
    static var secondaryTextColor: XColor {
        return Asset.blackSecondaryTextColor.color
    }

    static var separatorColor: XColor {
        return Asset.blackSeparatorColor.color
    }

    static var buttonColor: XColor {
        return Asset.blackTransparent.color
    }

    static var accentSuperLightColor: XColor {
        return Asset.blackAccentSuperLight.color
    }

    static var accentLightColor: XColor {
        return Asset.blackAccentLight.color
    }

    static var textColor: XColor {
        return Asset.blackTextColor.color
    }

    static var backgroundColor: XColor {
        return .black
    }
}

struct LightTheme: ColorTheme {
    static var secondaryTextColor: XColor {
        return Asset.secondaryTextColor.color
    }

    static var separatorColor: XColor {
        return UIColor.gray
    }

    static var buttonColor: XColor {
        return Asset.whiteTransparent.color
    }

    static var accentSuperLightColor: XColor {
        return Asset.accentSuperLight.color
    }

    static var accentLightColor: XColor {
        return Asset.accentLight.color
    }

    static var textColor: XColor {
        return .darkText
    }

    static var backgroundColor: XColor {
        return .white
    }
}

struct GrayTheme: ColorTheme {
    static var secondaryTextColor: XColor {
        return Asset.blackSecondaryTextColor.color
    }

    static var separatorColor: XColor {
        return UIColor.darkGray
    }

    static var buttonColor: XColor {
        return .black
    }
    
    static var accentSuperLightColor: XColor {
        return Asset.blackAccentSuperLight.color
    }

    static var accentLightColor: XColor {
        return Asset.blackAccentLight.color
    }

    static var textColor: XColor {
        return .lightGray
    }

    static var backgroundColor: XColor {
        return Asset.grayBackgroundColor.color
    }
}

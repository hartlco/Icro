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
    public static let accentLight = XColor(named: "accentLight")!
    public static let accentSuperLight = XColor(named: "accentSuperLight")!
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
}

public enum Theme {
    case light
    case gray
    case black

    public static let currentTheme = Theme.gray

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
    static var backgroundColor: XColor { get }
}

struct BlackTheme: ColorTheme {
    static var textColor: XColor {
        return .white
    }

    static var backgroundColor: XColor {
        return .black
    }
}

struct LightTheme: ColorTheme {
    static var textColor: XColor {
        return .darkText
    }

    static var backgroundColor: XColor {
        return .white
    }
}

struct GrayTheme: ColorTheme {
    static var textColor: XColor {
        return .lightGray
    }

    static var backgroundColor: XColor {
        return XColor(named: "gray-backgroundColor")!
    }
}

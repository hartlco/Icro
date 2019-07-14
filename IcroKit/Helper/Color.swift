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
    public static let yellow = XColor(named: "yellow")!
    public static let accentDark = XColor(named: "accentDark")!
    public static let separatorColor = UIColor.separator

    public static var backgroundColor: XColor {
        return UIColor.systemBackground
    }
    public static var textColor: XColor {
        return UIColor.label
    }
    public static var secondaryTextColor: XColor {
        return UIColor.secondaryLabel
    }
    public static let buttonColor = XColor(named: "whiteTransparent")
    public static let successColor = XColor(named: "success")
}

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
    public static let accentSuperLight = XColor(named: "accentSuperLight")!
    public static let accent = XColor(named: "accent")!
    public static let yellow = XColor(named: "yellow")
    public static let accentDark = XColor(named: "accentDark")!
    public static let separatorColor = XColor(named: "separatorColor")!
}

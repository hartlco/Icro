//
//  Created by martin on 26.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

public extension Theme {
    var keyboardAppearance: UIKeyboardAppearance {
        switch Theme.currentTheme {
        case .black, .gray:
            return .dark
        case .light:
            return .light
        }
    }
}

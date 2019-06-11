//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

extension Date {
    private static let relativeDateFormatter = RelativeDateTimeFormatter()

    var timeAgo: String {
        Date.relativeDateFormatter.unitsStyle = .abbreviated
        return Date.relativeDateFormatter.localizedString(for: self, relativeTo: Date())
    }
}

//
//  Created by martin on 22.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

extension Date {
    private static let formatter: DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .abbreviated
        formatter.maximumUnitCount = 1
        return formatter
    }()

    func formattedDateComponents() -> String? {
        let unitFlags: Set<Calendar.Component> = [.year, .month, .weekOfMonth, .day, .hour, .minute, .second]

        var components = Calendar.current.dateComponents(unitFlags, from: self, to: Date())

        var uppercase = false
        if (components.year ?? 0) > 0 {
            components.month = 0
            components.weekOfMonth = 0
            components.day = 0
            components.hour = 0
            components.minute = 0
            components.second = 0
            uppercase = true
        } else if (components.month ?? 0) > 0 {
            components.weekOfMonth = 0
            components.day = 0
            components.hour = 0
            components.minute = 0
            components.second = 0
            uppercase = true
        } else if (components.weekOfMonth ?? 0) > 0 {
            components.day = 0
            components.hour = 0
            components.minute = 0
            components.second = 0
        } else if (components.day ?? 0) > 0 {
            components.hour = 0
            components.minute = 0
            components.second = 0
        } else if (components.hour ?? 0) > 0 {
            components.minute = 0
            components.second = 0
        } else if (components.minute ?? 0) > 0 {
            components.second = 0
        }
        if uppercase {
            return Date.formatter.string(from: components)?.uppercased()
        } else {
            return Date.formatter.string(from: components)
        }
    }
}

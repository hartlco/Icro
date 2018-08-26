//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

extension Date {
    var timeAgo: String {
        return self.formattedDateComponents() ?? ""
    }
}

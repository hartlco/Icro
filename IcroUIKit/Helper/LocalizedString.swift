//
//  Created by martin on 16.12.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

public func localizedString(key: String) -> String {
    let bundle = Bundle(for: ItemCellConfigurator.self)
    return NSLocalizedString(key, tableName: nil, bundle: bundle, value: "", comment: "")
}

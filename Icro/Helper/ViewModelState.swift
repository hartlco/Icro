//
//  Created by Martin Hartl on 30.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation

enum ViewModelState<Content> {
    case initial
    case loading
    case loaded(content: Content)
    case error(_ error: Error)
}

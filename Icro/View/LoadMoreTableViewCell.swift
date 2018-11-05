//
//  Created by martin on 04.11.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit

class LoadMoreTableViewCell: UITableViewCell {
    static let identifier = "LoadMoreTableViewCell"

    var didPressLoadMore: (() -> Void)?

    @IBAction func loadMorePressed(_ sender: Any) {
        didPressLoadMore?()
    }
}

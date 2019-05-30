//
//  Created by Martin Hartl on 30.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

enum TableViewScrollAction {
    case up
    case down
    case top
    case bottom
}

extension UITableView {
    func scroll(action: TableViewScrollAction) {
        switch action {
        case .up:
            scrollUp()
        case .down:
            scrollDown()
        default:
            return
        }
    }

    private func scrollUp() {
        guard let firstVisibleIndexPath = indexPathsForVisibleRows?.first,
            firstVisibleIndexPath.row > 0 else { return }

        let previousIndexPath = IndexPath(row: firstVisibleIndexPath.row - 1, section: firstVisibleIndexPath.section)

        scrollToRow(at: previousIndexPath, at: .bottom, animated: true)
    }

    private func scrollDown() {
        guard let lastVisibleIndexPath = indexPathsForVisibleRows?.last,
            lastVisibleIndexPath.row + 1 < numberOfRows(inSection: lastVisibleIndexPath.section) else { return }

        let previousIndexPath = IndexPath(row: lastVisibleIndexPath.row + 1, section: lastVisibleIndexPath.section)

        scrollToRow(at: previousIndexPath, at: .top, animated: true)
    }
}

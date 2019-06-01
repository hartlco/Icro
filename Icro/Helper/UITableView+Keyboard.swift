//
//  Created by Martin Hartl on 30.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

enum TableViewScrollAction {
    // swiftlint:disable identifier_name
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
        case .top:
            scrollToTop()
        case .bottom:
            scrollToBottom()
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

    private func scrollToTop() {
        guard numberOfSections > 0, numberOfRows(inSection: 0) > 0 else { return }

        scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
    }

    private func scrollToBottom() {
        let lastSection = numberOfSections - 1
        guard lastSection > -1 else { return }
        let lastRow = numberOfRows(inSection: lastSection) - 1
        guard lastRow > -1 else { return }
        scrollToRow(at: IndexPath(row: lastRow, section: lastSection), at: .top, animated: true)
    }
}

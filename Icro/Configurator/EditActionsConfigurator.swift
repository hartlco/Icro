//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import TypedSymbols

final class EditActionsConfigurator {
    private let itemNavigator: ItemNavigator
    private let viewModel: ListViewModel

    var didModifyIndexPath: ((IndexPath) -> Void)?

    init(itemNavigator: ItemNavigator,
         viewModel: ListViewModel) {
        self.itemNavigator = itemNavigator
        self.viewModel = viewModel
    }

    func canEdit(at indexPath: IndexPath) -> Bool {
        switch viewModel.viewType(forRow: indexPath.row) {
        case .author, .loadMore:
            return false
        case .item:
            return true
        }
    }

    func tralingEditActions(at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration? {
        guard case .item(let item) = viewModel.viewType(forRow: indexPath.row) else { return nil }
        let cell = tableView.cellForRow(at: indexPath)

        let conversationAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_CONVERSATIONACTION", comment: "")) { [weak self] _, _, _ in
            self?.itemNavigator.openConversation(item: item)
            tableView.setEditing(false, animated: true)
        }
        conversationAction.backgroundColor = Color.main
        conversationAction.image = UIImage(symbol: .bubble_left_and_bubble_right)

        let shareAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_SHAREACTION", comment: "")) { [weak self] _, _, _ in
            self?.itemNavigator.share(item: item, sourceView: cell!)
            tableView.setEditing(false, animated: true)
        }
        shareAction.backgroundColor = Color.accent
        shareAction.image = UIImage(symbol: .square_and_arrow_up)

        return UISwipeActionsConfiguration(actions: [conversationAction, shareAction])
    }

    func leadingEditActions(at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath)
        guard case .item(let item) = viewModel.viewType(forRow: indexPath.row) else { return nil }
        let replyAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_LEADINGEDITACTIONS", comment: "")) { [weak self] _, _, _ in
            self?.itemNavigator.openReply(item: item)
            self?.didModifyIndexPath?(indexPath)
            tableView.setEditing(false, animated: true)
        }
        replyAction.backgroundColor = Color.accentDark
        replyAction.image = UIImage(symbol: .arrowshape_turn_up_left)

        let moreAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_MOREACTION",
                                                        comment: "")) { [weak self] _, _, _ in
            tableView.setEditing(false, animated: true)
            self?.itemNavigator.openMore(item: item, sourceView: cell)
        }
        moreAction.backgroundColor = Color.separatorColor
        moreAction.image = UIImage(symbol: .ellipsis)

        let title = item.isFavorite ?
            NSLocalizedString("EDITACTIONSCONFIGURATOR_FAVORITEACTION_UNFAVORITE", comment: "") :
            NSLocalizedString("EDITACTIONSCONFIGURATOR_FAVORITEACTION_FAVORITE", comment: "")
        let favoriteAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, _ in
            tableView.setEditing(false, animated: true)
            self?.viewModel.toggleFave(for: item)
        }
        favoriteAction.backgroundColor = Color.yellow

        let image = item.isFavorite ? UIImage(symbol: .star_fill) : UIImage(symbol: .star)

        favoriteAction.image = image

        return UISwipeActionsConfiguration(actions: [replyAction, favoriteAction, moreAction])
    }

    func contextMenu(at indexPath: IndexPath) -> UIContextMenuConfiguration? {
//        return UIContextMenuConfiguration(identifier: nil,
//                                   previewProvider: nil) { (element) -> UIMenu<UIAction>? in
//
//
//        }

//        UIContextMenuConfiguration(identifier: nil,
//                                   previewProvider: nil) { (elements) -> UIMenu<UIAction>? in
//                                    return UIMenu<UIAction>(title: "Test", children: [])
//        }

        return nil
    }
}

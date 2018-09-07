//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import FontAwesome_swift

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
        switch viewModel.viewType(for: indexPath.section, row: indexPath.row) {
        case .author:
            return false
        case .item:
            return true
        }
    }

    func tralingEditActions(at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration? {
        let item = viewModel.item(for: indexPath.row)
        let cell = tableView.cellForRow(at: indexPath)

        let conversationAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_CONVERSATIONACTION", comment: "")) { [weak self] _, _, _ in
            self?.itemNavigator.openConversation(item: item)
            tableView.setEditing(false, animated: true)
        }
        conversationAction.backgroundColor = Color.main
        conversationAction.image = UIImage.fontAwesomeIcon(name: .comments,
                                                           textColor: .white,
                                                           size: CGSize(width: 30, height: 30))

        let shareAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_SHAREACTION", comment: "")) { [weak self] _, _, _ in
            guard let item = self?.viewModel.item(for: indexPath.row) else { return }
            self?.itemNavigator.share(item: item, sourceView: cell!)
            tableView.setEditing(false, animated: true)
        }
        shareAction.backgroundColor = Color.accent
        shareAction.image = UIImage.fontAwesomeIcon(name: .shareSquareO,
                                                    textColor: .white,
                                                    size: CGSize(width: 30, height: 30))

        return UISwipeActionsConfiguration(actions: [conversationAction, shareAction])
    }

    func leadingEditActions(at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath)
        let item = viewModel.item(for: indexPath.row)
        let replyAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_LEADINGEDITACTIONS", comment: "")) { [weak self] _, _, _ in
            self?.itemNavigator.openReply(item: item)
            self?.didModifyIndexPath?(indexPath)
            tableView.setEditing(false, animated: true)
        }
        replyAction.backgroundColor = Color.accentDark
        replyAction.image = UIImage.fontAwesomeIcon(name: .reply,
                                                    textColor: .white,
                                                    size: CGSize(width: 30, height: 30))

        let moreAction =
            UIContextualAction(style: .normal,
                               title: NSLocalizedString("EDITACTIONSCONFIGURATOR_MOREACTION",
                                                        comment: "")) { [weak self] _, _, _ in
            tableView.setEditing(false, animated: true)
            self?.itemNavigator.openMore(item: item, sourceView: cell)
        }
        moreAction.backgroundColor = Color.separatorColor
        moreAction.image = UIImage.fontAwesomeIcon(name: .ellipsisH,
                                                   textColor: .white,
                                                   size: CGSize(width: 30, height: 30))

        let title = item.isFavorite ?
            NSLocalizedString("EDITACTIONSCONFIGURATOR_FAVORITEACTION_UNFAVORITE", comment: "") :
            NSLocalizedString("EDITACTIONSCONFIGURATOR_FAVORITEACTION_FAVORITE", comment: "")
        let favoriteAction = UIContextualAction(style: .normal, title: title) { [weak self] _, _, _ in
            tableView.setEditing(false, animated: true)
            self?.viewModel.toggleFave(for: item)
        }
        favoriteAction.backgroundColor = Color.yellow

        // swiftlint:disable line_length
        let image = item.isFavorite ? UIImage.fontAwesomeIcon(name: .star, textColor: .white, size: CGSize(width: 30, height: 30)) : UIImage.fontAwesomeIcon(name: .starO, textColor: .white, size: CGSize(width: 30, height: 30))

        favoriteAction.image = image

        return UISwipeActionsConfiguration(actions: [replyAction, favoriteAction, moreAction])
    }
}

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

    func tralingEditActions(at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration? {
        let item = viewModel.item(for: indexPath.row)
        let cell = tableView.cellForRow(at: indexPath)

        let conversationAction = UIContextualAction(style: .normal, title: "Chat") { [weak self] _, _, _ in
            self?.itemNavigator.openConversation(item: item)
            tableView.setEditing(false, animated: true)
        }
        conversationAction.title = nil
        conversationAction.backgroundColor = Color.main
        conversationAction.image = UIImage.fontAwesomeIcon(name: .comments,
                                                           textColor: .white,
                                                           size: CGSize(width: 30, height: 30))

        let shareAction = UIContextualAction(style: .normal, title: "Share") { [weak self] _, _, _ in
            guard let item = self?.viewModel.item(for: indexPath.row) else { return }
            self?.itemNavigator.share(item: item, sourceView: cell!)
            tableView.setEditing(false, animated: true)
        }
        shareAction.backgroundColor = Color.accent
        shareAction.title = nil
        shareAction.image = UIImage.fontAwesomeIcon(name: .shareSquareO,
                                                    textColor: .white,
                                                    size: CGSize(width: 30, height: 30))

        return UISwipeActionsConfiguration(actions: [conversationAction, shareAction])
    }

    func leadingEditActions(at indexPath: IndexPath, in tableView: UITableView) -> UISwipeActionsConfiguration? {
        let cell = tableView.cellForRow(at: indexPath)
        let item = viewModel.item(for: indexPath.row)
        let replyAction = UIContextualAction(style: .normal, title: "Reply") { [weak self] _, _, _ in
            self?.itemNavigator.openReply(item: item)
            self?.didModifyIndexPath?(indexPath)
            tableView.setEditing(false, animated: true)
        }
        replyAction.backgroundColor = Color.accentDark
        replyAction.title = nil
        replyAction.image = UIImage.fontAwesomeIcon(name: .reply,
                                                    textColor: .white,
                                                    size: CGSize(width: 30, height: 30))

        let moreAction = UIContextualAction(style: .normal, title: "Reply") { [weak self] _, _, _ in
            tableView.setEditing(false, animated: true)
            self?.itemNavigator.openMore(item: item, sourceView: cell)
        }

        moreAction.backgroundColor = Color.separatorColor
        moreAction.title = nil
        moreAction.image = UIImage.fontAwesomeIcon(name: .ellipsisH,
                                                   textColor: .white,
                                                   size: CGSize(width: 30, height: 30))

        let favoriteAction = UIContextualAction(style: .normal, title: "Favorite") { [weak self] _, _, _ in
            tableView.setEditing(false, animated: true)
            self?.viewModel.toggleFave(for: item)
        }

        favoriteAction.backgroundColor = Color.yellow
        favoriteAction.title = nil

        // swiftlint:disable line_length
        let image = item.isFavorite ? UIImage.fontAwesomeIcon(name: .star, textColor: .white, size: CGSize(width: 30, height: 30)) : UIImage.fontAwesomeIcon(name: .starO, textColor: .white, size: CGSize(width: 30, height: 30))

        favoriteAction.image = image

        return UISwipeActionsConfiguration(actions: [replyAction, favoriteAction, moreAction])
    }
}

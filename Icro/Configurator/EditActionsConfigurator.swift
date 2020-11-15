//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit
import TypedSymbols

final class EditActionsConfigurator {
    private struct ContextAction {
        let title: String
        let image: UIImage?
        let color: UIColor?
        let action: () -> Void

        func toUIAction() -> UIAction {
            return UIAction(title: title,
                            image: image) { _ in
                                self.action()
            }
        }

        func toSwipeAction() -> SwipeAction {
            let action = SwipeAction(style: .default,
                                     title: title) { _, _ in
                                        self.action()
            }

            action.image = image
            action.backgroundColor = color

            return action
        }
    }

    private let itemNavigator: ItemNavigatorProtocol
    private let viewModel: ListViewModel

    init(itemNavigator: ItemNavigatorProtocol,
         viewModel: ListViewModel) {
        self.itemNavigator = itemNavigator
        self.viewModel = viewModel
    }

    func menu(cell: ItemTableViewCell, indexPath: IndexPath, inConversation: Bool) -> UIMenu {
        guard case .item(let item) = viewModel.viewType(forRow: indexPath.row) else {
            fatalError("No item for indexPath")
        }

        let share = shareAction(for: item, sourceView: cell).toUIAction()
        let reply = replyAction(for: item).toUIAction()
        let favorite = favoriteAction(for: item).toUIAction()
        let conversation = conversationAction(for: item).toUIAction()

        var actions = [share, reply, favorite]

        if !inConversation {
            actions.insert(conversation, at: 2)
        }

        return UIMenu(title: "",
                      image: nil,
                      identifier: nil,
                      children: actions)
    }

    func contextMenu(tableView: UITableView, indexPath: IndexPath, inConversation: Bool) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil,
                                          previewProvider: nil,
                                          actionProvider: { _ in
            return self.makeContextMenu(tableView: tableView,
                                        indexPath: indexPath,
                                        inConversation: inConversation)
        })
    }

    func swipeActions(indexPath: IndexPath,
                      orientation: SwipeActionsOrientation,
                      inConversation: Bool) -> [SwipeAction]? {
        guard case .item(let item) = viewModel.viewType(forRow: indexPath.row) else {
            return nil
        }

        switch orientation {
        case .left:
            return [replyAction(for: item).toSwipeAction()]
        case .right:
            guard !inConversation else {
                return []
            }

            return [conversationAction(for: item).toSwipeAction()]
        }
    }

    // MARK: - Private

    private func makeContextMenu(tableView: UITableView,
                                 indexPath: IndexPath,
                                 inConversation: Bool) -> UIMenu {
        guard case .item(let item) = viewModel.viewType(forRow: indexPath.row),
            let cell = tableView.cellForRow(at: indexPath) else {
            return UIMenu(title: "", image: nil, identifier: nil, children: [])
        }

        let share = shareAction(for: item, sourceView: cell).toUIAction()
        let reply = replyAction(for: item).toUIAction()
        let favorite = favoriteAction(for: item).toUIAction()
        let conversation = conversationAction(for: item).toUIAction()

        var actions = [share, reply, favorite]

        if !inConversation {
            actions.insert(conversation, at: 2)
        }

        return UIMenu(title: "",
                      image: nil,
                      identifier: nil,
                      children: actions)
    }

    private func favoriteAction(for item: Item) -> ContextAction {
        let favoriteTitle = item.isFavorite ?
            NSLocalizedString("EDITACTIONSCONFIGURATOR_FAVORITEACTION_UNFAVORITE", comment: "") :
            NSLocalizedString("EDITACTIONSCONFIGURATOR_FAVORITEACTION_FAVORITE", comment: "")
        let favoriteImage = item.isFavorite ? UIImage(symbol: Symbol.heart_fill) : UIImage(symbol: Symbol.heart)
        let color = UIColor.systemYellow
        return ContextAction(title: favoriteTitle,
                             image: favoriteImage,
                             color: color) { [weak self] in
                                self?.viewModel.toggleFave(for: item)
        }
    }

    private func conversationAction(for item: Item) -> ContextAction {
        let title = NSLocalizedString("EDITACTIONSCONFIGURATOR_CONVERSATIONACTION", comment: "")
        return ContextAction(title: title,
                             image: UIImage(symbol: .bubble_left_and_bubble_right),
                             color: Color.accentDark,
                             action: { [weak self] in
                                self?.itemNavigator.openConversation(item: item)
        })
    }

    private func replyAction(for item: Item) -> ContextAction {
        let title = NSLocalizedString("EDITACTIONSCONFIGURATOR_LEADINGEDITACTIONS", comment: "")
        return ContextAction(title: title,
                             image: UIImage(symbol: Symbol.arrowshape_turn_up_left),
                             color: Color.accent) { [weak self] in
                                self?.itemNavigator.openReply(item: item)
        }
    }

    private func shareAction(for item: Item, sourceView: UIView) -> ContextAction {
        let title = NSLocalizedString("EDITACTIONSCONFIGURATOR_SHAREACTION", comment: "")
        return ContextAction(title: title,
                             image: UIImage(symbol: Symbol.square_and_arrow_up),
                             color: nil) { [weak self] in
                                self?.itemNavigator.share(item: item, sourceView: sourceView)
        }
    }
}

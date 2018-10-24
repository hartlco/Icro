//
//  ListViewController.swift
//  Icro-Mac
//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Cocoa
import IcroKit_Mac

class ListViewController: NSViewController, NSMenuItemValidation {
    private var resizingTextView = NSTextView()

    func validateMenuItem(_ menuItem: NSMenuItem) -> Bool {
        switch menuItem.identifier {
        case NSUserInterfaceItemIdentifier(rawValue: "ReplyIdentifier"),
             NSUserInterfaceItemIdentifier(rawValue: "OpenConversationIdentifier"):
            return !collectionView.selectionIndexes.isEmpty
        default:
            return true
        }
    }

    @IBOutlet weak var collectionView: NSCollectionView! {
        didSet {
            collectionView.delegate = self
            collectionView.dataSource = self
            collectionView.register(ListItemCell.nib, forItemWithIdentifier: ListItemCell.identifier)
            collectionView.isSelectable = true
        }
    }

    private let viewModel: ListViewModel
    private let itemCellConfigurator: ListItemCellConfigurator
    private let itemNavigator: ItemNavigator

    init(listViewModel: ListViewModel,
         itemNavigator: ItemNavigator) {
        self.viewModel = listViewModel
        self.itemCellConfigurator = ListItemCellConfigurator(itemNavigator: itemNavigator)
        self.itemNavigator = itemNavigator
        super.init(nibName: "ListViewController", bundle: nil)
    }

    required init?(coder: NSCoder) {
       fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.didFinishLoading = { [weak self] _ in
            guard let self = self else { return }
            self.collectionView.reloadData()
        }

        viewModel.load()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        collectionView.collectionViewLayout?.invalidateLayout()

    }

    override func viewWillLayout() {
        super.viewWillLayout()

        // When we're invalidating the collection view layout
        // it will call `collectionView(_:layout:sizeForItemAt:)` method
        collectionView.collectionViewLayout?.invalidateLayout()
    }

    func refresh() {
        viewModel.load()
    }

    @IBAction private func reply(sender: Any) {
        guard let firstIndex = collectionView.selectionIndexes.first else {
            return
        }

        let item = viewModel.item(for: firstIndex)

        itemNavigator.openReply(for: item)
    }

    @IBAction private func openConversation(sender: Any) {
        guard let firstIndex = collectionView.selectionIndexes.first else {
                return
        }

        let item = viewModel.item(for: firstIndex)
        itemNavigator.openConversation(for: item)
    }
}

extension ListViewController: NSCollectionViewDataSource, NSCollectionViewDelegate, NSCollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: NSCollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems(in: 0)
    }

    func collectionView(_ collectionView: NSCollectionView, itemForRepresentedObjectAt indexPath: IndexPath) -> NSCollectionViewItem {
        guard let itemCell = collectionView.makeItem(withIdentifier: ListItemCell.identifier, for: indexPath) as? ListItemCell else {
            fatalError("Cell could not be dequed")
        }
        let item = viewModel.item(for: indexPath.item)
        itemCellConfigurator.configure(itemCell, forDisplaying: item)
        return itemCell
    }

    func collectionView(_ collectionView: NSCollectionView,
                        layout collectionViewLayout: NSCollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> NSSize {
        let item = viewModel.item(for: indexPath.item)
        let someWidth: CGFloat = collectionView.bounds.size.width - 70
        let frame: NSRect = NSRect(x: 0, y: 0, width: someWidth, height: CGFloat.greatestFiniteMagnitude)
        let textView = resizingTextView
        resizingTextView.frame = frame

        textView.textStorage?.setAttributedString(item.content)
        textView.isHorizontallyResizable = false
        textView.sizeToFit()

        let imageHeight: CGFloat = item.images.isEmpty ? 0 : 160

        let height = textView.frame.size.height + 40 + imageHeight
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
    }
}

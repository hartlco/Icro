//
//  ListViewController.swift
//  Icro-Mac
//
//  Created by martin on 06.10.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Cocoa
import IcroKit_Mac

class ListViewController: NSViewController {
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

    init(listViewModel: ListViewModel,
         itemNavigator: ItemNavigator) {
        self.viewModel = listViewModel
        self.itemCellConfigurator = ListItemCellConfigurator(itemNavigator: itemNavigator)
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

    override var representedObject: Any? {
        didSet {
            // Update the view, if already loaded.
        }
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
        let string = viewModel.item(for: indexPath.item).content.string
        let someWidth: CGFloat = collectionView.bounds.size.width
        let stringAttributes = [NSAttributedString.Key.font: Font().body]
        let attrString = NSAttributedString(string: string, attributes: stringAttributes)
        let frame: NSRect = NSMakeRect(0, 0, someWidth, CGFloat.greatestFiniteMagnitude)
        let tv = NSTextView(frame: frame)
        tv.textStorage?.setAttributedString(attrString)
        tv.isHorizontallyResizable = false
        tv.sizeToFit()

        let item = viewModel.item(for: indexPath.item)
        let imageHeight: CGFloat = item.images.isEmpty ? 0 : 160

        let height = tv.frame.size.height + 80 + imageHeight
        return CGSize(width: collectionView.bounds.width, height: height)
    }

    func collectionView(_ collectionView: NSCollectionView, didSelectItemsAt indexPaths: Set<IndexPath>) {
        
    }
}


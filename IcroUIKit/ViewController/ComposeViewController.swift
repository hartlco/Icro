//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import MobileCoreServices
import Style
import SwiftUI
import Kingfisher
import Sourceful
import UniformTypeIdentifiers

private struct Constants {
    static let KeyboardInputViewHeight = 40.0
}

public final class ComposeViewController: UIViewController, LoadingViewController {
    public var didClose: () -> Void = { }

    private var layoutGuide: KeyboardLayoutGuide?

    private let viewModel: ComposeViewModel
    private let composeNavigator: ComposeNavigatorProtocol

    private var cancelButton: UIBarButtonItem?
    private let itemNavigator: ItemNavigatorProtocol
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.registerClass(cellType: ItemTableViewCell.self)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet weak var syntaxView: SyntaxTextView! {
        didSet {
            syntaxView.delegate = self
            syntaxView.theme = IcroEditorTheme()
            syntaxView.contentTextView.isScrollEnabled = false
            syntaxView.contentTextView.autocorrectionType = .default
            syntaxView.contentTextView.autocapitalizationType = .sentences
            syntaxView.contentTextView.spellCheckingType = .default
        }
    }

    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.registerClass(cellType: SingleImageCollectionViewCell.self)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
        }
    }

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    public init(viewModel: ComposeViewModel,
                composeNavigator: ComposeNavigatorProtocol,
                itemNavigator: ItemNavigatorProtocol) {
        self.viewModel = viewModel
        self.composeNavigator = composeNavigator
        self.itemNavigator = itemNavigator

        super.init(nibName: nil, bundle: nil)

        navigationItem.leftBarButtonItem = cancelButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.backgroundColor
        syntaxView.text = viewModel.startText

        layoutGuide = KeyboardLayoutGuide(parentView: view)
        if let layoutGuide = layoutGuide {
            scrollView.bottomAnchor.constraint(equalTo: layoutGuide.topGuide.topAnchor,
                                               constant: -Constants.KeyboardInputViewHeight).isActive = true
        }

        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height

        updateImageCollection()
        let dropInteraction = UIDropInteraction(delegate: self)
        view.addInteraction(dropInteraction)
    }

    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if viewModel.showKeyboardOnAppear {
            syntaxView.contentTextView.becomeFirstResponder()
        }
    }

    // MARK: - Private

    @objc private func cancel() {
        syntaxView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        didClose()
    }

    private func updateImageCollection() {
        if viewModel.numberOfImages != 0 {
            collectionViewHeightConstraint.constant = 140
        } else {
            collectionViewHeightConstraint.constant = 0
        }
        imageCollectionView.reloadData()
        view.setNeedsLayout()
        view.layoutIfNeeded()
    }
}

extension ComposeViewController: UITableViewDelegate, UITableViewDataSource {
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.replyItem == nil ? 0 : 1
    }

    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return viewModel.replyItem == nil ? nil : localizedString(key: "COMPOSEVIEWCONTROLLER_TABLEVIEW_HEADER_TITLE")
    }

    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        view.tintColor = Color.backgroundColor
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Color.textColor
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueCell(ofType: ItemTableViewCell.self, for: indexPath)
        guard let item = viewModel.replyItem else {
            fatalError("Could not deque right item")
        }

        let cellConfigurator = ItemCellConfigurator(itemNavigator: itemNavigator)

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cellConfigurator.configure(cell, forDisplaying: item)

        return cell
    }
}

extension ComposeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfImages
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueCell(ofType: SingleImageCollectionViewCell.self, for: indexPath)
        let image = viewModel.image(at: indexPath.row)
        cell.imageView.kf.setImage(with: image.link)

        return cell
    }

    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let dataSource = viewModel.galleryDataSource(for: indexPath.row)
        dataSource.removeAtIndex = { [weak self] index in
            guard let self = self else { return }
            self.viewModel.removeImage(at: index)
        }
        composeNavigator.open(datasource: dataSource)
    }
}

extension ComposeViewController: UIDropInteractionDelegate {
    public func dropInteraction(_ interaction: UIDropInteraction, canHandle session: UIDropSession) -> Bool {
        return session.canLoadObjects(ofClass: UIImage.self) && session.items.count == 1
    }

    public func dropInteraction(_ interaction: UIDropInteraction, sessionDidUpdate session: UIDropSession) -> UIDropProposal {
        let operation = UIDropOperation.copy
        return UIDropProposal(operation: operation)
    }

    public func dropInteraction(_ interaction: UIDropInteraction, performDrop session: UIDropSession) {
        session.loadObjects(ofClass: UIImage.self) { imageItems in
            guard let images = imageItems as? [UIImage], let firstImage = images.first else {
                return
            }

            self.viewModel.upload(image: firstImage)
        }
    }
}

extension ComposeViewController: SyntaxTextViewDelegate {
    public func lexerForSource(_ source: String) -> Lexer {
        return IcroLexer()
    }
}

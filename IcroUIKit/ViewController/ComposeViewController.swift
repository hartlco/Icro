//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import MobileCoreServices
import IcroKit
import Kingfisher
import Sourceful

private struct Constants {
    static let KeyboardInputViewHeight: CGFloat = 40.0
}

public final class ComposeViewController: UIViewController, LoadingViewController {
    public var didClose: () -> Void = { }

    private var layoutGuide: KeyboardLayoutGuide?

    fileprivate let viewModel: ComposeViewModel
    private let composeNavigator: ComposeNavigatorProtocol

    private var cancelButton: UIBarButtonItem?
    private let itemNavigator: ItemNavigatorProtocol
    fileprivate let keyboardInputView = KeyboardInputView.instanceFromNib()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(cellType: ItemTableViewCell.self)
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
            imageCollectionView.register(cellType: SingleImageCollectionViewCell.self)
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
        super.init(nibName: "ComposeViewController", bundle: Bundle(for: ComposeViewController.self))
        title = localizedString(key: "COMPOSEVIEWCONTROLLER_TITLE")
        cancelButton = UIBarButtonItem(title: localizedString(key: "COMPOSEVIEWCONTROLLER_CANCELBUTTON_TITLE"),
                                       style: .plain, target: self, action: #selector(cancel))
        let sendButton = UIBarButtonItem(title: localizedString(key: "KEYBOARDINPUTVIEW_POSTBUTTON_TITLE"),
                                       style: .plain, target: self, action: #selector(post))
        keyboardInputView.postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        keyboardInputView.linkButton.addTarget(self, action: #selector(insertLink), for: .touchUpInside)
        keyboardInputView.imageButton.addTarget(self, action: #selector(insertImage), for: .touchUpInside)
        keyboardInputView.cancelButton.addTarget(self, action: #selector(canelImageUpload), for: .touchUpInside)

        viewModel.didUpdateImages = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateImageCollection()
            strongSelf.keyboardInputView.update(for: strongSelf.syntaxView.text,
                                                numberOfImages: strongSelf.viewModel.numberOfImages,
                                                imageState: strongSelf.viewModel.imageState)
        }

        viewModel.didChangeImageState = { [weak self] imageState in
            guard let strongSelf = self else { return }
            strongSelf.keyboardInputView.update(for: strongSelf.syntaxView.text,
                                                numberOfImages: strongSelf.viewModel.numberOfImages,
                                                imageState: strongSelf.viewModel.imageState)
        }

        navigationItem.leftBarButtonItem = cancelButton
        navigationItem.rightBarButtonItem = sendButton
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
        setupKeyboardInputView()
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

    private func setupKeyboardInputView() {
        keyboardInputView.update(for: viewModel.startText,
                                 numberOfImages: viewModel.numberOfImages,
                                 imageState: viewModel.imageState)
        keyboardInputView.backgroundColor = Color.accentSuperLight
        keyboardInputView.translatesAutoresizingMaskIntoConstraints = false
        keyboardInputView.addConstraint(NSLayoutConstraint(item: keyboardInputView,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: Constants.KeyboardInputViewHeight))

        keyboardInputView.imageButton.isHidden = !viewModel.canUploadImage

        view.addSubview(keyboardInputView)
        if let layoutGuide = layoutGuide {
            keyboardInputView.bottomAnchor.constraint(equalTo: layoutGuide.topGuide.topAnchor).isActive = true
            keyboardInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
            keyboardInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        }
    }

    @objc private func cancel() {
        syntaxView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        didClose()
    }

    @objc private func post() {
        resignFirstResponder()
        showLoading(position: .top)

        setButtonState(enabled: false)

        viewModel.post(string: syntaxView.text) { [weak self] error in
            self?.setButtonState(enabled: true)
            if let error = error {
                self?.showError(error: error, position: .top)
            } else {
                self?.hideMessage()
                self?.dismiss(animated: true, completion: nil)
                self?.didClose()
            }
        }
    }

    @objc private func insertLink() {
        composeNavigator.openLinkInsertion { [weak self] title, url in
            guard let title = title, let url = url else { return }
            self?.syntaxView.insertText(self?.viewModel.linkText(url: url,
                                                               title: title) ?? "")
        }
    }

    @objc private func insertImage() {
        syntaxView.resignFirstResponder()
        composeNavigator.openImageInsertion(sourceView: keyboardInputView.imageButton, imageInsertion: { [weak self] image in
            self?.viewModel.insertImage(image: image)
        }, imageUpload: { [weak self] image in
            self?.viewModel.upload(image: image)
        })
    }

    @objc private func canelImageUpload() {
        viewModel.cancelImageUpload()
    }

    private func setButtonState(enabled: Bool) {
        cancelButton?.isEnabled = enabled
        keyboardInputView.postButton.isEnabled = enabled
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
        cellConfigurator.configure(cell, forDisplaying: item, showActionButton: false)

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
        return session.hasItemsConforming(toTypeIdentifiers: [kUTTypeImage as String]) && session.items.count == 1
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

    public func didChangeText(_ syntaxTextView: SyntaxTextView) {
        keyboardInputView.update(for: syntaxTextView.text, numberOfImages: viewModel.numberOfImages, imageState: viewModel.imageState)
    }
}

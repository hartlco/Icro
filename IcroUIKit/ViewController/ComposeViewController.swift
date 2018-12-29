//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import SDWebImage

public final class ComposeViewController: UIViewController, LoadingViewController {
    public var didClose: () -> Void = { }

    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.font = Font().body
            textView.keyboardAppearance = Theme.currentTheme.keyboardAppearance
        }
    }
    fileprivate let viewModel: ComposeViewModel
    private let composeNavigator: ComposeNavigatorProtocol

    private var cancelButton: UIBarButtonItem?
    private let itemNavigator: ItemNavigatorProtocol
    fileprivate let keyboardInputView = KeyboardInputView.instanceFromNib()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: ItemTableViewCell.identifer, bundle: Bundle(for: ComposeViewController.self)),
                               forCellReuseIdentifier: ItemTableViewCell.identifer)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.register(UINib(nibName: SingleImageCollectionViewCell.identifier,
                                               bundle: Bundle(for: ComposeViewController.self)),
                                        forCellWithReuseIdentifier: SingleImageCollectionViewCell.identifier)
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
        keyboardInputView.postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        keyboardInputView.linkButton.addTarget(self, action: #selector(insertLink), for: .touchUpInside)
        keyboardInputView.imageButton.addTarget(self, action: #selector(insertImage), for: .touchUpInside)
        keyboardInputView.cancelButton.addTarget(self, action: #selector(canelImageUpload), for: .touchUpInside)

        viewModel.didUpdateImages = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.updateImageCollection()
            strongSelf.keyboardInputView.update(for: strongSelf.textView.text,
                                                numberOfImages: strongSelf.viewModel.numberOfImages,
                                                imageState: strongSelf.viewModel.imageState)
        }

        viewModel.didChangeImageState = { [weak self] imageState in
            guard let strongSelf = self else { return }
            strongSelf.keyboardInputView.update(for: strongSelf.textView.text,
                                                numberOfImages: strongSelf.viewModel.numberOfImages,
                                                imageState: strongSelf.viewModel.imageState)
        }

        navigationItem.leftBarButtonItem = cancelButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.backgroundColor
        textView.text = viewModel.startText

        let layoutGuide = KeyboardLayoutGuide(parentView: view).topGuide
        scrollView.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor).isActive = true

        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height

        updateImageCollection()

        setupKeyboardInputView()
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    // MARK: - Private

    private func setupKeyboardInputView() {
        keyboardInputView.update(for: viewModel.startText,
                                 numberOfImages: viewModel.numberOfImages,
                                 imageState: viewModel.imageState)
        keyboardInputView.translatesAutoresizingMaskIntoConstraints = false
        keyboardInputView.addConstraint(NSLayoutConstraint(item: keyboardInputView,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: 40))

        keyboardInputView.imageButton.isHidden = !viewModel.canUploadImage

        textView.inputAccessoryView = keyboardInputView
    }

    @objc private func cancel() {
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
        didClose()
    }

    @objc private func post() {
        resignFirstResponder()
        showLoading(position: .top)

        setButtonState(enabled: false)

        viewModel.post(string: textView.text) { [weak self] error in
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
            self?.textView.insertText(self?.viewModel.linkText(url: url,
                                                               title: title) ?? "")
        }
    }

    @objc private func insertImage() {
        textView.resignFirstResponder()
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

    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.replyItem == nil ? nil : localizedString(key: "COMPOSEVIEWCONTROLLER_TABLEVIEW_HEADER_TITLE")
    }

    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        view.tintColor = Color.backgroundColor
        guard let header = view as? UITableViewHeaderFooterView else { return }
        header.textLabel?.textColor = Color.textColor
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifer, for: indexPath) as? ItemTableViewCell,
        let item = viewModel.replyItem else {
            fatalError("Could not deque right cell")
        }

        let cellConfigurator = ItemCellConfigurator(itemNavigator: itemNavigator)

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cellConfigurator.configure(cell, forDisplaying: item)

        return cell
    }
}

extension ComposeViewController: UITextViewDelegate {
    public func textViewDidChange(_ textView: UITextView) {
        keyboardInputView.update(for: textView.text, numberOfImages: viewModel.numberOfImages, imageState: viewModel.imageState)
    }
}

extension ComposeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfImages
    }

    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleImageCollectionViewCell.identifier,
                                                            for: indexPath) as? SingleImageCollectionViewCell else {
            fatalError("Could not deque SingleImageCollectionViewCell")
        }

        let image = viewModel.image(at: indexPath.row)
        cell.imageView.sd_setImage(with: image.link)

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

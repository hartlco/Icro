//
//  Created by martin on 02.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import KeyboardLayoutGuide
import ImageViewer
import SDWebImage

final class ComposeViewController: UIViewController {
    @IBOutlet private weak var textView: UITextView! {
        didSet {
            textView.delegate = self
            textView.font = Font().body
        }
    }
    fileprivate let viewModel: ComposeViewModel
    private let composeNavigator: ComposeNavigator

    private var cancelButton: UIBarButtonItem?
    fileprivate let keyboardInputView = KeyboardInputView.instanceFromNib()
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet private weak var tableView: UITableView! {
        didSet {
            tableView.register(UINib(nibName: ItemTableViewCell.identifer, bundle: nil),
                               forCellReuseIdentifier: ItemTableViewCell.identifer)
            tableView.delegate = self
            tableView.dataSource = self
        }
    }
    @IBOutlet private weak var tableViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var imageCollectionView: UICollectionView! {
        didSet {
            imageCollectionView.register(UINib(nibName: SingleImageCollectionViewCell.identifier,
                                               bundle: nil), forCellWithReuseIdentifier: SingleImageCollectionViewCell.identifier)
            imageCollectionView.delegate = self
            imageCollectionView.dataSource = self
        }
    }

    @IBOutlet weak var collectionViewHeightConstraint: NSLayoutConstraint!

    init(viewModel: ComposeViewModel,
         composeNavigator: ComposeNavigator) {
        self.viewModel = viewModel
        self.composeNavigator = composeNavigator
        super.init(nibName: "ComposeViewController", bundle: nil)
        title = NSLocalizedString("COMPOSEVIEWCONTROLLER_TITLE", comment: "")
        cancelButton = UIBarButtonItem(title: NSLocalizedString("COMPOSEVIEWCONTROLLER_CANCELBUTTON_TITLE", comment: ""),
                                       style: .plain, target: self, action: #selector(cancel))
        keyboardInputView.postButton.addTarget(self, action: #selector(post), for: .touchUpInside)
        keyboardInputView.linkButton.addTarget(self, action: #selector(insertLink), for: .touchUpInside)
        keyboardInputView.imageButton.addTarget(self, action: #selector(insertImage), for: .touchUpInside)
        keyboardInputView.cancelButton.addTarget(self, action: #selector(canelImageUpload), for: .touchUpInside)

        viewModel.didUpdateImages = { [weak self] in
            self?.updateImageCollection()
        }

        viewModel.didChangeImageState = { [weak self] imageState in
            self?.keyboardInputView.update(for: imageState)
        }

        navigationItem.leftBarButtonItem = cancelButton
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        textView.text = viewModel.startText

        scrollView.bottomAnchor.constraint(equalTo: view.keyboardLayoutGuide.topAnchor).isActive = true

        tableView.reloadData()
        tableView.layoutIfNeeded()
        tableViewHeightConstraint.constant = tableView.contentSize.height

        updateImageCollection()

        setupKeyboardInputView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        textView.becomeFirstResponder()
    }

    // MARK: - Private

    private func setupKeyboardInputView() {
        keyboardInputView.text = viewModel.startText
        keyboardInputView.translatesAutoresizingMaskIntoConstraints = false
        keyboardInputView.addConstraint(NSLayoutConstraint(item: keyboardInputView,
                                                           attribute: .height,
                                                           relatedBy: .equal,
                                                           toItem: nil,
                                                           attribute: .notAnAttribute,
                                                           multiplier: 1,
                                                           constant: 40))
        textView.inputAccessoryView = keyboardInputView
    }

    @objc private func cancel() {
        textView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }

    @objc private func post() {
        resignFirstResponder()
        showLoading(position: .top)

        setButtonState(enabled: false)

        viewModel.post(string: textView.text) { [weak self] error in
            self?.setButtonState(enabled: true)
            if let error = error {
                self?.showError(position: .top, error: error)
            } else {
                self?.hideMessage()
                self?.dismiss(animated: true, completion: nil)
            }
        }
    }

    @objc private func insertLink() {
        composeNavigator.openLinkInsertion { [weak self] title, url in
            guard let title = title, let url = url else { return }
            self?.textView.insertText("[\(title)](\(url))")
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.replyItem == nil ? 0 : 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.replyItem == nil ? nil : NSLocalizedString("COMPOSEVIEWCONTROLLER_TABLEVIEW_HEADER_TITLE", comment: "")
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: ItemTableViewCell.identifer, for: indexPath) as? ItemTableViewCell,
        let navigationController = navigationController,
        let item = viewModel.replyItem else {
            fatalError("Could not deque right cell")
        }

        let cellConfigurator = ItemCellConfigurator(itemNavigator: ItemNavigator(navigationController: navigationController))

        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        cellConfigurator.configure(cell, forDisplaying: item)

        return cell
    }
}

extension ComposeViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        keyboardInputView.text = textView.text
    }
}

extension ComposeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfImages
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SingleImageCollectionViewCell.identifier,
                                                            for: indexPath) as? SingleImageCollectionViewCell else {
            fatalError("Could not deque SingleImageCollectionViewCell")
        }

        let image = viewModel.image(at: indexPath.row)
        cell.imageView.sd_setImage(with: image.link)

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        composeNavigator.open(datasource: self, delegate: self, at: indexPath.row)
    }
}

extension ComposeViewController: GalleryItemsDataSource {
    func itemCount() -> Int {
        return viewModel.numberOfImages
    }

    func provideGalleryItem(_ index: Int) -> GalleryItem {
        let image = viewModel.image(at: index)
        return GalleryItem.image { completion in
            SDWebImageDownloader().downloadImage(with: image.link, options: [], progress: nil, completed: { image, _, _, _ in
                DispatchQueue.main.async {
                    completion(image)
                }
            })
        }
    }
}

extension ComposeViewController: GalleryItemsDelegate {
    func removeGalleryItem(at index: Int) {
        viewModel.removeImage(at: index)
    }
}

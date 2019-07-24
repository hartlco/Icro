//
//  Created by martin on 13.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import IcroKit
import IcroUIKit

final class ComposeNavigator: NSObject, ComposeNavigatorProtocol {
    private let navigationController: UINavigationController
    private let viewModel: ComposeViewModel
    fileprivate var imageSelection: ((UIImage) -> Void)?

    public init(navigationController: UINavigationController,
                viewModel: ComposeViewModel) {
        self.navigationController = navigationController
        self.viewModel = viewModel
    }

    func openLinkInsertion(completion: @escaping (String?, URL?) -> Void) {
        let viewController = InsertLinkViewController()
        viewController.completion = completion
        navigationController.pushViewController(viewController, animated: true)
    }

    func openImageInsertion(sourceView: UIView?,
                            imageInsertion: @escaping (ComposeViewModel.Image) -> Void,
                            imageUpload: @escaping (UIImage) -> Void) {
        let alert = UIAlertController(title:
            NSLocalizedString("COMPOSENAVIGATOR_OPENIMAGEALERT_TITLE", comment: ""),
                                      message: nil, preferredStyle: .actionSheet)

        alert.addAction(UIAlertAction(title:
            NSLocalizedString("COMPOSENAVIGATOR_OPENIMAGEALERT_CANCELACTION", comment: ""),
                                      style: .cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
        }))

        alert.addAction(UIAlertAction(title:
            NSLocalizedString("COMPOSENAVIGATOR_OPENIMAGEALERT_URLACTION", comment: ""),
                                      style: .default, handler: { [weak self] _ in
            let viewController = InsertLinkViewController()
            viewController.completion = { title, url in
                guard let title = title, let url = url else { return }
                imageInsertion(ComposeViewModel.Image(title: title, link: url))
            }
            self?.navigationController.pushViewController(viewController, animated: true)
        }))

        if viewModel.imageUploadEnabled {
            alert.addAction(UIAlertAction(title:
                NSLocalizedString("COMPOSENAVIGATOR_OPENIMAGEALERT_UPLOADACTION", comment: ""),
                                          style: .default, handler: { [weak self] _ in
                self?.showImagePicker(sourceView: sourceView)
                self?.imageSelection = { image in
                    imageUpload(image)
                }
            }))
        }

        alert.popoverPresentationController?.sourceView = sourceView

        navigationController.present(alert, animated: true, completion: nil)
    }

    func open(datasource: GalleryDataSource) {
        let gallery = GalleryViewController(startIndex: datasource.index, itemsDataSource: datasource, itemsDelegate: datasource)
        navigationController.presentImageGallery (gallery)
    }

    private func showImagePicker(sourceView: UIView?) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = false
        imagePicker.modalPresentationStyle = .popover
        imagePicker.popoverPresentationController?.sourceView = sourceView
        navigationController.present(imagePicker, animated: true, completion: nil)
    }
}

extension ComposeNavigator: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        imageSelection?(image)
        picker.dismiss(animated: true, completion: nil)
    }
}

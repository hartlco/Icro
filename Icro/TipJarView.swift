//
//  Created by martin on 27.01.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

final class TipJarView: UIView {
    private let viewModel: TipJarViewModel
    private let collectionView: UICollectionView

    var purchaseStateChanged: ((TipJarViewModel.State) -> Void)?

    init(viewModel: TipJarViewModel) {
        self.viewModel = viewModel
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: 120, height: 120)
        self.collectionView = UICollectionView(frame: CGRect.zero,
                                               collectionViewLayout: layout)
        collectionView.contentInset = UIEdgeInsets(top: 2, left: 10, bottom: 10, right: 10)
        super.init(frame: CGRect.zero)
        translatesAutoresizingMaskIntoConstraints = false
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        collectionView.pin(to: self)
        collectionView.backgroundColor = Color.accentSuperLight
        collectionView.register(UINib(nibName: TipCollectionViewCell.identifier, bundle: nil),
                                forCellWithReuseIdentifier: TipCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        viewModel.load()

        viewModel.stateChanged = { [weak self] state in
            guard let self = self else { return }

            switch state {
            case .loaded, .unloaded:
                self.collectionView.reloadData()
            case .purchasing:
                self.collectionView.isUserInteractionEnabled = false
            case .loading, .purchased, .purchasingError, .cancelled:
                self.collectionView.isUserInteractionEnabled = true
            }

            self.purchaseStateChanged?(state)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension TipJarView: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfProducts
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TipCollectionViewCell.identifier,
                                                            for: indexPath) as? TipCollectionViewCell else {
            fatalError("Could not deque TipJar collection view cell")
        }

        let item = viewModel.product(at: indexPath.row)

        cell.productTitleLabel.text = item.title
        cell.productPriceLabel.text = item.price
        cell.contentView.backgroundColor = Color.backgroundColor

        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        viewModel.purchaseProduct(at: indexPath.row)
    }
}

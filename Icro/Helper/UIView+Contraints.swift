//
//  Created by martin on 27.01.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import UIKit

extension UIView {
    func pin(to view: UIView) {
        leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }

    func pin(toSafeAreaFrom view: UIView) {
        leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor).isActive = true
        trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor).isActive = true
        topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }

    func pin(to view: UIView, inset: UIEdgeInsets) {
        leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: inset.left).isActive = true
        trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -inset.right).isActive = true
        topAnchor.constraint(equalTo: view.topAnchor, constant: inset.top).isActive = true
        bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -inset.bottom).isActive = true
    }
}

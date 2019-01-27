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
}

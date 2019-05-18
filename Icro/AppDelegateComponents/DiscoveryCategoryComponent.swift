//
//  Created by Martin Hartl on 12.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import AppDelegateComponent

final class DiscoveryCategoryComponent: AppDelegateComponent {
    private let categoryStore: DiscoveryCategoryStore

    init(categoryStore: DiscoveryCategoryStore = DiscoveryCategoryStore()) {
        self.categoryStore = categoryStore
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        categoryStore.update()
        return true
    }
}

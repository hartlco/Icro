//
//  Created by Martin Hartl on 18.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import AppDelegateComponent

final class AppearanceComponent: AppDelegateComponent {
    private let appearanceManager: AppearanceManager

    init(appearanceManager: AppearanceManager = .init()) {
        self.appearanceManager = appearanceManager
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]?) -> Bool {
        appearanceManager.applyAppearance()
        return true
    }
}

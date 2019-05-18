//
//  Created by Martin Hartl on 18.05.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit
import AppDelegateComponent

final class BackgroundFetchComponent: AppDelegateComponent {
    private let viewModel = ListViewModel(type: .timeline)

    func application(_ app: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        viewModel.load()
        viewModel.didFinishLoading = { cached in
            guard !cached else { return }
            completionHandler(.newData)
        }

        viewModel.didFinishWithError = { _ in
            completionHandler(.failed)
        }
    }
}

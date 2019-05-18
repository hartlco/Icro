//
//  Created by Martin Hartl on 12.05.19.
//

import UIKit

public protocol AppDelegateComponent {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool

    func application(_ app: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)
}

// Default implementations
public extension AppDelegateComponent {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) { }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
    }

    func application(_ app: UIApplication, performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }
}

public protocol AppDelegateComponentStore {
    var storedComponents: [AppDelegateComponent] { get }
}

final public class AppDelegateComponentRunner {
    public init() { }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                        application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) {
        componentStore.storedComponents.forEach {
            $0.application(application,
                           didFinishLaunchingWithOptions: launchOptions)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               app: UIApplication,
                               open url: URL,
                               options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        return componentStore.storedComponents.reduce(false, { result, component in
            return result || component.application(app, open: url, options: options)
        })
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               app: UIApplication,
                               performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let completionGroup = DispatchGroup()
        var results = [UIBackgroundFetchResult]()
        for component in componentStore.storedComponents {
            completionGroup.enter()
            component.application(app) { result in
                results.append(result)
                completionGroup.leave()
            }
        }

        completionGroup.notify(queue: .main) {
            let finalResult: UIBackgroundFetchResult

            if results.contains(.newData) {
                finalResult = .newData
            } else if results.contains(.failed) {
                finalResult = .failed
            } else {
                finalResult = .noData
            }

            completionHandler(finalResult)
        }
    }
}

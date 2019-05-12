//
//  Created by Martin Hartl on 12.05.19.
//

import UIKit

public protocol AppDelegateComponent {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?)

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

// Default implementations
public extension AppDelegateComponent {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) { }

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return true
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
}

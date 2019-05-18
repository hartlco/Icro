//
//  Created by Martin Hartl on 12.05.19.
//

import UIKit

public protocol AppDelegateComponent {
    // MARK: - Initializing the App

    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool

    // MARK: - Responding to App State Changes and System Events

    func applicationDidBecomeActive(_ application: UIApplication)

    func applicationWillResignActive(_ application: UIApplication)

    func applicationDidEnterBackground(_ application: UIApplication)

    func applicationWillEnterForeground(_ application: UIApplication)

    func applicationWillTerminate(_ application: UIApplication)

    // MARK: - Downloading Data in the Background

    func application(_ app: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    // MARK: - Handling Remote Notification Registration

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data)

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error)

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void)

    // MARK: - Opening a URL-Specified Resource

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool
}

// Default implementations
public extension AppDelegateComponent {
    func application(_ application: UIApplication,
                     willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) { }

    func applicationWillResignActive(_ application: UIApplication) { }

    func applicationDidEnterBackground(_ application: UIApplication) { }

    func applicationWillEnterForeground(_ application: UIApplication) { }

    func applicationWillTerminate(_ application: UIApplication) { }

    func application(_ app: UIApplication,
                     performFetchWithCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(.noData)
    }

    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) { }

    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) { }

    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        completionHandler(UIBackgroundFetchResult.noData)
    }

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
                               willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return componentStore.storedComponents.map { component in
            component.application(application, willFinishLaunchingWithOptions: launchOptions)
        }.contains(true)
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                        application: UIApplication,
                        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return componentStore.storedComponents.map { component in
            component.application(application, didFinishLaunchingWithOptions: launchOptions)
        }.contains(true)
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               applicationDidBecomeActive app: UIApplication) {
        componentStore.storedComponents.forEach {
            $0.applicationDidBecomeActive(app)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               applicationWillResignActive app: UIApplication) {
        componentStore.storedComponents.forEach {
            $0.applicationWillResignActive(app)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               applicationDidEnterBackground app: UIApplication) {
        componentStore.storedComponents.forEach {
            $0.applicationDidEnterBackground(app)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               applicationWillEnterForeground app: UIApplication) {
        componentStore.storedComponents.forEach {
            $0.applicationWillEnterForeground(app)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               applicationWillTerminate app: UIApplication) {
        componentStore.storedComponents.forEach {
            $0.applicationWillTerminate(app)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               app: UIApplication,
                               open url: URL,
                               options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {

        return componentStore.storedComponents.map { component in
            component.application(app, open: url, options: options)
        }.contains(true)
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               app: UIApplication,
                               didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        componentStore.storedComponents.forEach {
            $0.application(app, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
        }
    }

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                               app: UIApplication,
                               didFailToRegisterForRemoteNotificationsWithError error: Error) {
        componentStore.storedComponents.forEach {
            $0.application(app, didFailToRegisterForRemoteNotificationsWithError: error)
        }
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

    public func componentStore(_ componentStore: AppDelegateComponentStore,
                        app: UIApplication,
                        didReceiveRemoteNotification userInfo: [AnyHashable : Any],
                        fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        let completionGroup = DispatchGroup()
        var results = [UIBackgroundFetchResult]()
        for component in componentStore.storedComponents {
            completionGroup.enter()
            component.application(app, didReceiveRemoteNotification: userInfo) { result in
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

//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import SwiftUI
import Combine
import Settings
import Client

final class LoginViewModel: ObservableObject {
    let objectWillChange = ObservableObjectPublisher()

    enum LoginType {
        case mail
        case token
    }

    var didLogin: (LoginInformation) -> Void = { _ in }
    var didDismiss: () -> Void = { }

    private var didRequest = false {
        willSet {
            objectWillChange.send()
        }
    }

    var isLoading = false {
        willSet {
            objectWillChange.send()
        }
    }

    var loginString = "" {
        willSet {
            objectWillChange.send()
        }

        didSet {
            infoMessage = nil
            didRequest = false
        }
    }

    var buttonActivated: Bool {
        return loginString.count > 0 && !isLoading && !didRequest
    }

    var buttonString: String {
        switch loginType {
        case .mail:
            return NSLocalizedString("LOGINVIEWMODEL_LOGINTYPE_MAIL", comment: "")
        case .token:
            return NSLocalizedString("LOGINVIEWMODEL_LOGINTYPE_TOKEN", comment: "")
        }
    }

    var infoMessage: String? {
        willSet {
            objectWillChange.send()
        }
    }

    private let userSettings: UserSettings
    private let client: Client

    init(userSettings: UserSettings = .shared,
         client: Client = URLSession.shared) {
        self.userSettings = userSettings
        self.client = client
    }

    func login() {
        switch loginType {
        case .mail:
            requestLoginMail()
        case .token:
            login(withToken: loginString)
        }
    }

    private func requestLoginMail() {
        isLoading = true

        guard let emailRequestResource = emailRequestResource else {
            self.infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
            self.isLoading = false
            self.didRequest = false
            return
        }

        client.load(resource: emailRequestResource) { _ in
            self.isLoading = false
            self.didRequest = true
            self.infoMessage = NSLocalizedString("LOGINVIEWCONTROLLER_INFOLABEL_TEXT", comment: "")
        }
    }

    private func login(withToken token: String) {
        isLoading = true

        guard let loginRequestResource = loginRequestResource(token: token) else {
            self.infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
            self.isLoading = false
            self.didRequest = false
            return
        }

        client.load(resource: loginRequestResource) { [weak self] info in
            guard let self = self else { return }

            self.isLoading = false
            self.didRequest = true

            guard let info = info.value else {
                self.infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
                return
            }
            self.userSettings.save(loginInformation: info)
            self.didLogin(info)
            self.loginString = ""
        }
    }

    private var loginType: LoginType {
        return loginString.contains("@") ? .mail : .token
    }

    private var emailRequestResource: Resource<Empty>? {
        let mail = loginString.replacingOccurrences(of: " ", with: "")
        let baseURLString = "https://micro.blog/account/signin?email=\(mail)&app_name=Icro&redirect_url=icro://"
        guard let url = URL(string: baseURLString) else {
            return nil
        }
        return Resource<Empty>(url: url,
                                       httpMethod: .post(nil),
                                       authorization: .plain(token: userSettings.token),
                                       parseJSON: { _ in
                                        return Empty()
        })
    }

    private func loginRequestResource(token: String) -> Resource<LoginInformation>? {
        let baseURLString = "https://micro.blog/account/verify?token=\(token)"
        guard let url = URL(string: baseURLString) else {
            return nil
        }
        return Resource<LoginInformation>(url: url,
                                          httpMethod: .post(nil),
                                          authorization: .plain(token: userSettings.token),
                                          parseJSON: { json in
                                            guard let json = json as? JSONDictionary else { return nil }
                                            return LoginInformation(json: json)
        })
    }
}

//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation
import IcroKit

final class LoginViewModel {
    enum LoginType {
        case mail
        case token
    }

    var updateState: () -> Void = { }
    var didStartLoading: () -> Void = { }
    var didFinishLoading: () -> Void = { }
    var didFinishWithError: (Error) -> Void = { _ in }

    var didLogin: (LoginInformation) -> Void = { _ in }

    private var didRequest = false
    private var isLoading = false

    var loginString = "" {
        didSet {
            updateState()
            didRequest = false
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

    func requestLoginMail() {
        isLoading = true
        updateState()
        didStartLoading()

        guard let emailRequestResource = emailRequestResource else {
            didFinishWithError(NetworkingError.invalidInput)
            self.isLoading = false
            self.didRequest = false
            updateState()
            return
        }

        client.load(resource: emailRequestResource) { _ in
            self.isLoading = false
            self.didRequest = true
            self.didFinishLoading()
            self.updateState()
        }
    }

    func login(withToken token: String) {
        isLoading = true
        updateState()
        didStartLoading()

        guard let loginRequestResource = loginRequestResource(token: token) else {
            didFinishWithError(NetworkingError.invalidInput)
            self.isLoading = false
            self.didRequest = false
            updateState()
            return
        }

        client.load(resource: loginRequestResource) { info in
            self.isLoading = false
            self.didRequest = true
            self.didFinishLoading()

            guard let info = info.value else { return }
            self.userSettings.save(loginInformation: info)
            self.didLogin(info)
        }
    }

    var buttonActivated: Bool {
        return loginString.count > 0 && !isLoading && !didRequest
    }

    var loginType: LoginType {
        return loginString.contains("@") ? .mail : .token
    }

    var buttonString: String {
        switch loginType {
        case .mail:
            return NSLocalizedString("LOGINVIEWMODEL_LOGINTYPE_MAIL", comment: "")
        case .token:
            return NSLocalizedString("LOGINVIEWMODEL_LOGINTYPE_TOKEN", comment: "")
        }
    }

    var infoLabelVisible: Bool {
        return didRequest
    }

    var emailRequestResource: Resource<Empty>? {
        let mail = loginString.replacingOccurrences(of: " ", with: "")
        let baseURLString = "https://micro.blog/account/signin?email=\(mail)&app_name=Icro&redirect_url=icro://"
        guard let url = URL(string: baseURLString) else {
            return nil
        }
        return Resource<Empty>(url: url, httpMethod: .post(nil), parseJSON: { _ in
            return Empty()
        })
    }

    func loginRequestResource(token: String) -> Resource<LoginInformation>? {
        let baseURLString = "https://micro.blog/account/verify?token=\(token)"
        guard let url = URL(string: baseURLString) else {
            return nil
        }
        return Resource<LoginInformation>(url: url, httpMethod: .post(nil), parseJSON: { json in
            guard let json = json as? JSONDictionary else { return nil }
            return LoginInformation(json: json)
        })
    }
}

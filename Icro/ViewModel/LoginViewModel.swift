//
//  Created by martin on 19.04.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import Foundation

struct LoginInformation: Codable {
    let token: String
    let username: String
    let defaultSite: String

    init?(json: JSONDictionary) {
        guard let token = json["token"] as? String,
            let username = json["username"] as? String else {
                return nil
        }

        self.token = token
        self.username = username
        self.defaultSite = (json["default_site"] as? String) ?? "micro.blog"
    }
}

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

    init(userSettings: UserSettings = .shared) {
        self.userSettings = userSettings
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

        Webservice().load(resource: emailRequestResource) { _ in
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

        Webservice().load(resource: loginRequestResource) { info in
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
            return "Login with mail"
        case .token:
            return "Login with access token"
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
        return Resource<Empty>(url: url, httpMethod: "POST", parseJSON: { _ in
            return Empty()
        })
    }

    func loginRequestResource(token: String) -> Resource<LoginInformation>? {
        let baseURLString = "https://micro.blog/account/verify?token=\(token)"
        guard let url = URL(string: baseURLString) else {
            return nil
        }
        return Resource<LoginInformation>(url: url, httpMethod: "POST", parseJSON: { json in
            guard let json = json as? JSONDictionary else { return nil }
            return LoginInformation(json: json)
        })
    }
}

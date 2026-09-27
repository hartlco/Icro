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

    enum LoginType: CaseIterable, Hashable {
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

    var loginType: LoginType = .mail {
        willSet { objectWillChange.send() }
        didSet {
            guard oldValue != loginType else { return }
            loginString = ""
        }
    }

    var buttonActivated: Bool {
        return !loginString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !isLoading && !didRequest
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

    @MainActor func login() {
        guard buttonActivated else { return }
        isLoading = true
        Task {
            switch loginType {
            case .mail:
                await requestLoginMail()
            case .token:
                await login(withToken: loginString)
            }
        }
    }

    @MainActor func login(tokenFromLink token: String) {
        loginType = .token
        loginString = token
        login()
    }

    @MainActor private func requestLoginMail() async {
        isLoading = true

        guard let emailRequestResource = emailRequestResource else {
            self.infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
            self.isLoading = false
            self.didRequest = false
            return
        }

        do {
            _ = try await client.load(resource: emailRequestResource)
            isLoading = false
            didRequest = true
            infoMessage = NSLocalizedString("LOGINVIEWCONTROLLER_INFOLABEL_TEXT", comment: "")
        } catch {
            infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_ERROR_TEXT", comment: "")
            isLoading = false
        }
    }

    @MainActor private func login(withToken token: String) async {
        isLoading = true

        guard let loginRequestResource = loginRequestResource(token: token) else {
            self.infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
            self.isLoading = false
            self.didRequest = false
            return
        }

        do {
            let info = try await client.load(resource: loginRequestResource)

            userSettings.save(loginInformation: info)
            didLogin(info)
            self.loginString = ""
        } catch {
            infoMessage = NSLocalizedString("UIVIEWCONTROLLERLOADING_INVALIDINPUT_TEXT", comment: "")
        }

        isLoading = false
        didRequest = false
    }

    private var emailRequestResource: Resource<Empty>? {
        guard let url = URL(string: "https://micro.blog/account/signin"),
              let body = formBody([
                URLQueryItem(name: "email", value: loginString.trimmingCharacters(in: .whitespacesAndNewlines)),
                URLQueryItem(name: "app_name", value: "Icro"),
                URLQueryItem(name: "redirect_url", value: "icro://")
              ]) else {
            return nil
        }
        return Resource<Empty>(url: url,
                                       httpMethod: .post(body),
                                       authorization: nil,
                                       contentType: "application/x-www-form-urlencoded",
                                       parseJSON: { _ in Empty()
        })
    }

    private func loginRequestResource(token: String) -> Resource<LoginInformation>? {
        guard let url = URL(string: "https://micro.blog/account/verify"),
              let body = formBody([URLQueryItem(name: "token", value: token.trimmingCharacters(in: .whitespacesAndNewlines))]) else {
            return nil
        }
        return Resource<LoginInformation>(url: url,
                                          httpMethod: .post(body),
                                          authorization: nil,
                                          contentType: "application/x-www-form-urlencoded",
                                          parseJSON: { json in
                                            guard let json = json as? JSONDictionary else { return nil }
                                            return LoginInformation(json: json)
        })
    }

    private func formBody(_ queryItems: [URLQueryItem]) -> Data? {
        let allowed = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._*")
        let fields = queryItems.compactMap { item -> String? in
            guard let value = item.value?.addingPercentEncoding(withAllowedCharacters: allowed) else { return nil }
            return "\(item.name)=\(value)"
        }
        guard fields.count == queryItems.count else { return nil }
        return fields.joined(separator: "&").data(using: .utf8)
    }
}

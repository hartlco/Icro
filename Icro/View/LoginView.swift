//
//  LoginView.swift
//  Icro
//
//  Created by martin on 13.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @ObjectBinding private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List {
                Section {
                    TextField($viewModel.loginString,
                              placeholder: Text("Mail address or access token"))
                    Text(viewModel.infoMessage ?? "Login with mail address or access token")
                    .lineLimit(nil)
                    .font(.footnote)
                }
                Section {
                    LoginButton(loading: $viewModel.isLoading,
                                enabled: viewModel.buttonActivated,
                                label: Text(viewModel.buttonString)) {
                        self.viewModel.login()
                    }
                }
            }
            .listStyle(.grouped)
            .navigationBarItems(trailing:
                Button(action: {
                    self.viewModel.didDismiss()
                }, label: {
                    Text("Cancel")
                })
            )
            .navigationBarTitle(Text("Login"))
        }
    }
}

struct LoginButton: View {
    @Binding var loading: Bool
    var enabled: Bool
    var label: Text
    var action: () -> Void

    var body: some View {
        HStack {
            Button(action: {
                self.action()
            }, label: {
                label
            })
            .disabled(!enabled)
            Spinner(loading: $loading)
        }
    }
}

struct Spinner: UIViewRepresentable {
    @Binding var loading: Bool

    func makeUIView(context: UIViewRepresentableContext<Spinner>) -> UIActivityIndicatorView {
        let indicator = UIActivityIndicatorView(style: .medium)
        return indicator
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<Spinner>) {
        if loading {
            uiView.startAnimating()
        } else {
            uiView.stopAnimating()
        }
    }
}

#if DEBUG
struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView(viewModel: LoginViewModel())
    }
}
#endif

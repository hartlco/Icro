//
//  Created by Martin Hartl on 13.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct LoginView: View {
    @ObservedObject private var viewModel: LoginViewModel

    init(viewModel: LoginViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        NavigationView {
            List {
                Section(footer: Text("LOGINVIEWCONTROLLER_TEXTFIELDINFO_TEXT").lineLimit(nil)) {
                    TextField("LOGINVIEWCONTROLLER_TEXTFIELD_PLACEHOLDER",
                              text: $viewModel.loginString)
                            .disableAutocorrection(true)
                            .autocapitalization(UITextAutocapitalizationType.none)
                    viewModel.infoMessage.map {
                        Text($0)
                    }
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
            .listStyle(GroupedListStyle())
            .navigationBarItems(leading:
                Button(action: {
                    self.viewModel.didDismiss()
                }, label: {
                    Text("ITEMNAVIGATOR_MOREALERT_CANCELACTION")
                })
            )
            .navigationBarTitle(Text("LOGINVIEWCONTROLLER_TITLE"))
        }
        .navigationViewStyle(StackNavigationViewStyle())
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

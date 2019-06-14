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

    var backgroundColor: Color {
        return Color("accentLight")
    }

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Footer")) {
                    TextField($viewModel.loginString,
                              placeholder: Text("Placeholder"))
                }
                Section {
                    Button(action: {
                        self.viewModel.login()
                    }, label: {
                        Text("Login")
                    })
                    .disabled(!viewModel.buttonActivated)
                }
            }
            .listStyle(.grouped)
            .navigationBarTitle(Text("Login"))
            .navigationBarItems(trailing:
                Button(action: {
                    print("Help tapped!")
                }, label: {
                    Text("Cancel")
                })
            )
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

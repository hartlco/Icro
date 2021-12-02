//
//  SwiftUIView.swift
//  Icro
//
//  Created by martinhartl on 02.12.21.
//  Copyright © 2021 Martin Hartl. All rights reserved.
//

import SwiftUI

struct LoginOverlayView: View {
    private let didSelectLogin: () -> Void

    init(didSelectLogin: @escaping () -> Void) {
        self.didSelectLogin = didSelectLogin
    }

    var body: some View {
        VStack(spacing: 10.0) {
            Text("You need to be logged in")
                .font(.headline)
            Button {
                didSelectLogin()
            } label: {
                Text("Log In")
                    .font(.headline)
            }

        }
    }
}

struct LoginOverlayView_Previews: PreviewProvider {
    static var previews: some View {
        LoginOverlayView {
            print("Login")
        }
    }
}

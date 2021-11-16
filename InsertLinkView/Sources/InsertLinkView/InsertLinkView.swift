//
//  Created by martin on 13.05.18.
//  Copyright © 2018 Martin Hartl. All rights reserved.
//

import UIKit
import Style
import SwiftUI

@available(iOS 15.0, *)
public struct InsertLinkView: View {
    private enum Field: Int, Hashable {
        case title, link
    }

    private let completion: ((String?, URL?) -> Void)?

    @FocusState private var focusField: Field?
    @State private var title = ""
    @State private var linkText = ""

    public init(completion: ((String?, URL?) -> Void)?) {
        self.completion = completion
    }

    public var body: some SwiftUI.View {
        Form {
            Section {
                TextField(
                    localizedString(key: "INSERTLINKVIEWCONTROLLER_TITLETEXTFIELD_TEXT"),
                    text: $title
                ).onSubmit {
                    focusField = .link
                }
                TextField(
                    localizedString(key: "INSERTLINKVIEWCONTROLLER_LINKTEXTFIELD_TEXT"),
                    text: $linkText
                ).focused($focusField, equals: .link)
            }
        }
        Button {
            completion?(title, URL(string: linkText))
        } label: {
            Text(localizedString(key: "INSERTLINKVIEWCONTROLLER_INSERTBUTTON_TITLE"))
                .frame(maxWidth: 300)
        }
        .frame(maxWidth: .infinity)
        .buttonStyle(.borderedProminent)
        .tint(Color(Style.Color.accent))
        .controlSize(.large)
        .padding()
        .navigationTitle(localizedString(key: "INSERTLINKVIEWCONTROLLER_TITLE"))
    }
}

private func localizedString(key: String) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: Bundle.module, value: "", comment: "")
}

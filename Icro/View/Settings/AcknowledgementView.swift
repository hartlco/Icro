//
//  Created by Martin Hartl on 29.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct Acknow {
    let title: String
    let text: String
}

final class AcknowledgmentViewModel {
    var acknows: [Acknow] {
        return []
    }
}

struct AcknowledgementView: View {
    private let viewModel = AcknowledgmentViewModel()

    var body: some View {
        Form {
            ForEach(viewModel.acknows, id: \Acknow.title) { ackno in
                NavigationLink(destination: AcknowledgementDetailView(acknow: ackno)) {
                    Text(ackno.title)
                }
            }
        }
        .navigationBarTitle(Text("SETTINGSVIEWCONTROLLER_ACKNOWLEDGMENTSBUTTON_TITLE"))
    }
}

struct AcknowledgementDetailView: View {
    let acknow: Acknow

    var body: some View {
        List {
            Text(acknow.text)
            .lineLimit(nil)
        }
        .padding()
        .navigationBarTitle(Text(acknow.title))
    }
}

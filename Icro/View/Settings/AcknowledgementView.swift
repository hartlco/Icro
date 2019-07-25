//
//  Created by Martin Hartl on 29.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct Acknow: Codable {
    let title: String
    let text: String
}

final class AcknowledgmentViewModel {
    private let fileManager: FileManager
    private let bundle: Bundle

    init(fileManager: FileManager = .default,
         bundle: Bundle = .main) {
        self.fileManager = fileManager
        self.bundle = bundle
    }

    var acknows: [Acknow] {
        guard let filePath = bundle.path(forResource: "acknowledgements", ofType: "json"),
            let data = fileManager.contents(atPath: filePath),
        let acknows = try? JSONDecoder().decode([Acknow].self, from: data) else { return [] }

        return acknows
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

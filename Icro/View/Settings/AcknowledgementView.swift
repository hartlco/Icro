//
//  Created by Martin Hartl on 29.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import AcknowList

final class AcknowledgmentViewModel {
    var acknows: [Acknow] {
        guard let path = AcknowledgmentViewModel.defaultAcknowledgementsPlistPath() else { return [] }
        let parser = AcknowParser(plistPath: path)
        return parser.parseAcknowledgements()
    }

    class func acknowledgementsPlistPath(name: String) -> String? {
        return Bundle.main.path(forResource: name, ofType: "plist")
    }

    class func defaultAcknowledgementsPlistPath() -> String? {
        guard let bundleName = Bundle.main.infoDictionary?["CFBundleName"] as? String else {
            return nil
        }

        let defaultAcknowledgementsPlistName = "Pods-\(bundleName)-acknowledgements"
        let defaultAcknowledgementsPlistPath = self.acknowledgementsPlistPath(name: defaultAcknowledgementsPlistName)

        if let defaultAcknowledgementsPlistPath = defaultAcknowledgementsPlistPath,
            FileManager.default.fileExists(atPath: defaultAcknowledgementsPlistPath) {
            return defaultAcknowledgementsPlistPath
        } else {
            return self.acknowledgementsPlistPath(name: "Pods-acknowledgements")
        }
    }
}

extension Acknow: Identifiable {
    public var id: String {
        return title
    }
}

struct AcknowledgementView: View {
    private let viewModel = AcknowledgmentViewModel()

    var body: some View {
        Form {
            ForEach(viewModel.acknows) { ackno in
                NavigationButton(destination: AcknowledgementDetailView(acknow: ackno)) {
                    Text(ackno.title)
                }
            }
        }
        .navigationBarTitle(Text("Acknowledgments"))
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

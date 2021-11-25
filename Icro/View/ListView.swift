//
//  Created by Martin Hartl on 09.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct ListView: UIViewControllerRepresentable {
    let itemNavigator: ItemNavigatorProtocol
    let viewModel: ListViewModel

    func makeUIViewController(context: UIViewControllerRepresentableContext<ListView>) -> ListViewController {
        return ListViewController(viewModel: viewModel, itemNavigator: itemNavigator)
    }

    func updateUIViewController(_ uiViewController: ListViewController,
                                context: UIViewControllerRepresentableContext<ListView>) { }
}

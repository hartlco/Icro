//
//  Created by Martin Hartl on 23.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @ObservedObject var viewModel: TipJarViewModel
    @Environment(\.purchase) private var purchase

    var body: some View {
        ForEach(viewModel.products) { product in
            Button {
                Task { await viewModel.purchase(product, using: purchase) }
            } label: {
                HStack {
                    Text(product.displayName)
                    Spacer()
                    Text(product.displayPrice)
                        .foregroundStyle(.secondary)
                }
            }
            .disabled(!AppStore.canMakePayments)
        }
    }
}

#if DEBUG
struct TipJarView_Previews: PreviewProvider {
    static var previews: some View {
        TipJarView(viewModel: TipJarViewModel())
    }
}
#endif

//
//  Created by Martin Hartl on 23.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI

struct TipJarView: View {
    @ObservedObject var viewModel: TipJarViewModel

    var body: some View {
        List(viewModel.products) { product in
            Button(action: {
                self.viewModel.purchase(product: product)
            }, label: {
                HStack {
                    Text(product.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                    Spacer(minLength: 10)
                    Group {
                        Text(product.price)
                            .foregroundColor(.red)
                        }
                        .padding(.all, 8)
                }
            })
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

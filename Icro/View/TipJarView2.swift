//
//  Created by Martin Hartl on 23.06.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import SwiftUI
import IcroKit

struct TipJarView2: View {
    @ObjectBinding var viewModel: TipJarViewModel
    private let cardColor = SwiftUI.Color("accentSuperLight")

    var body: some View {
        HStack {
            ScrollView {
                HStack(spacing: 20) {
                    ForEach(viewModel.products) { product in
                        Button(action: {
                            self.viewModel.purchase(product: product)
                        }, label: {
                            VStack {
                                Text(product.title)
                                    .font(.headline)
                                    .color(.primary)
                                Spacer(minLength: 10)
                                Group {
                                    Text(product.price)
                                        .color(.red)
                                    }
                                    .padding(.all, 8)
                                    .border(Color.red,
                                            width: 1,
                                            cornerRadius: 4)
                            }
                        })
                        .padding()
                        .background(self.cardColor)
                        .cornerRadius(6)
                        .shadow(color: Color.black.opacity(0.2),
                                radius: 1, x: 0, y: 2)
                    }
                }
            }
            .frame(minHeight: 110)
        }
    }
}

#if DEBUG
struct TipJarView2_Previews: PreviewProvider {
    static var previews: some View {
        TipJarView2(viewModel: TipJarViewModel())
    }
}
#endif

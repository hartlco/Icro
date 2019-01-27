//
//  Created by martin on 27.01.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import StoreKit

final class TipJarViewModel: NSObject {
    private(set) var state = State.unloaded {
        didSet {
            stateChanged(state)
        }
    }

    private var products = [InAppPurchaseProduct]()

    enum State {
        case unloaded
        case loading
        case loaded(products: [InAppPurchaseProduct])
        case error
    }

    var stateChanged: ((State) -> Void) = { _ in }

    var numberOfProducts: Int {
        return products.count
    }

    func product(at index: Int) -> InAppPurchaseProduct {
        return products[index]
    }

    func load() {
        let identifiers = ["nice_tip"]
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        request.start()
    }

    func purchaseProduct(at index: Int) {
        if canMakePurchases {
            let purchase = product(at: index).product
            let payment = SKPayment(product: purchase)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            print("Purchase: \(purchase.productIdentifier)")
        }
    }

    private var canMakePurchases: Bool {
        return SKPaymentQueue.canMakePayments()
    }
}

extension TipJarViewModel: SKProductsRequestDelegate, SKPaymentTransactionObserver {
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
            case .purchased:
                print("Purchased")
            case .purchasing:
                print("Purchasing")
            case .failed:
                print("failed")
            default:
                print("default error")
            }
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products.compactMap {
            return InAppPurchaseProduct(identifier: $0.productIdentifier,
                                        title: $0.localizedTitle,
                                        price: priceOf(product: $0),
                                        product: $0)
        }
        state = .loaded(products: products)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
       state = .error
    }

    private func priceOf(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price)!
    }
}

struct InAppPurchaseProduct {
    let identifier: String
    let title: String
    let price: String
    let product: SKProduct
}

//
//  Created by martin on 27.01.19.
//  Copyright © 2019 Martin Hartl. All rights reserved.
//

import Foundation
import StoreKit
import IcroKit
import SwiftUI
import Combine

final class TipJarViewModel: NSObject, ObservableObject {
    var willChange = PassthroughSubject<Void, Never>()

    private(set) var state = State.unloaded {
        willSet {
            DispatchQueue.main.async {
                self.willChange.send()
            }
        }

        didSet {
            stateChanged(state)
        }
    }

    private(set) var products = [InAppPurchaseProduct]() {
        willSet {
            DispatchQueue.main.async {
                self.willChange.send()
            }
        }
    }

    enum State {
        case unloaded
        case loading
        case loaded(products: [InAppPurchaseProduct])
        case purchasing(message: String)
        case purchased(message: String)
        case purchasingError(error: Error)
        case cancelled
    }

    var stateChanged: ((State) -> Void) = { _ in }

    var numberOfProducts: Int {
        return products.count
    }

    override init() {
        super.init()
        load()
    }

    func product(at index: Int) -> InAppPurchaseProduct {
        return products[index]
    }

    func load() {
        let identifiers = ["nice_tip", "big_tip", "huge_tip"]
        let request = SKProductsRequest(productIdentifiers: Set(identifiers))
        request.delegate = self
        request.start()
        state = .loading
    }

    func purchase(product: InAppPurchaseProduct) {
        if canMakePurchases {
            let purchase = product.product
            let payment = SKPayment(product: purchase)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)

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
                state = .purchased(message: NSLocalizedString("IN-APP-PURCHASE-STATE-PURCHASED", comment: ""))
                queue.finishTransaction(transaction)
            case .deferred, .purchasing:
                state = .loading
            case .failed:
                if let error = transaction.error as? SKError,
                    error.code == SKError.paymentCancelled {
                    state = .cancelled
                    return
                }

                state = .purchasingError(error: PurchaseError.paymentError)
                queue.finishTransaction(transaction)
            case .restored:
                queue.finishTransaction(transaction)
                return
            }
        }
    }

    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        products = response.products.compactMap {
            return InAppPurchaseProduct(identifier: $0.productIdentifier,
                                        title: $0.localizedTitle,
                                        price: priceOf(product: $0),
                                        product: $0)
        }.sorted {
            return $0.price < $1.price
        }
        state = .loaded(products: products)
    }

    func request(_ request: SKRequest, didFailWithError error: Error) {
       state = .purchasingError(error: error)
    }

    private func priceOf(product: SKProduct) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = product.priceLocale
        return numberFormatter.string(from: product.price)!
    }
}

struct InAppPurchaseProduct: Identifiable {
    var id: String {
        return identifier
    }

    let identifier: String
    let title: String
    let price: String
    let product: SKProduct
}

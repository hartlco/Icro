import Foundation
import StoreKit
import SwiftUI

@MainActor
final class TipJarViewModel: ObservableObject {
    enum State {
        case unloaded
        case loading
        case loaded
        case purchasing(message: String)
        case purchased(message: String)
        case purchasingError(error: Error)
        case cancelled
    }

    @Published private(set) var state: State = .unloaded
    @Published private(set) var products: [Product] = []

    func load() async {
        guard case .unloaded = state else { return }
        state = .loading

        do {
            products = try await Product.products(for: ["nice_tip", "big_tip", "huge_tip"])
                .sorted { $0.price < $1.price }
            state = .loaded
        } catch {
            state = .purchasingError(error: error)
        }
    }

    func purchase(_ product: Product, using purchase: PurchaseAction) async {
        guard AppStore.canMakePayments else {
            state = .purchasingError(error: PurchaseError.paymentError)
            return
        }

        state = .purchasing(message: NSLocalizedString("IN-APP-PURCHASE-STATE-PURCHASING", comment: ""))

        do {
            switch try await purchase(product) {
            case .success(.verified(let transaction)):
                state = .purchased(message: NSLocalizedString("IN-APP-PURCHASE-STATE-PURCHASED", comment: ""))
                await transaction.finish()
            case .success(.unverified(_, let error)):
                state = .purchasingError(error: error)
            case .pending:
                state = .purchasing(message: NSLocalizedString("IN-APP-PURCHASE-STATE-PURCHASING", comment: ""))
            case .userCancelled:
                state = .cancelled
            @unknown default:
                state = .purchasingError(error: PurchaseError.paymentError)
            }
        } catch {
            state = .purchasingError(error: error)
        }
    }
}

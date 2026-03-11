import Foundation
import Combine
import CartInterface
import AnalyticsLib

protocol CartViewModelNavigationDelegate: AnyObject {
    func cartViewModel(_ viewModel: CartViewModel, didRequest event: CartViewModel.NavigationEvent)
}

final class CartViewModel {
    enum NavigationEvent {
        case productSelected(id: String)
        case checkoutTapped
    }

    weak var navigationDelegate: CartViewModelNavigationDelegate?

    @Published private(set) var cartItems: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0

    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(cartService: CartServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.cartService = cartService
        self.analytics = analytics
        bindCartService()
    }

    private func bindCartService() {
        cartService.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.cartItems = items
                self?.totalPrice = items.reduce(0) { $0 + $1.price * Double($1.quantity) }
            }
            .store(in: &cancellables)
    }

    func didSelectItem(productId: String) {
        navigationDelegate?.cartViewModel(self, didRequest: .productSelected(id: productId))
    }

    func didTapCheckout() {
        analytics.track(AnalyticsEvent(name: "checkout_started", parameters: [
            "item_count": "\(cartItems.count)",
            "total": "\(totalPrice)"
        ]))
        navigationDelegate?.cartViewModel(self, didRequest: .checkoutTapped)
    }

    func removeItem(productId: String) {
        cartService.removeItem(productId: productId)
        analytics.track(AnalyticsEvent(name: "cart_item_removed", parameters: ["product_id": productId]))
    }

    func updateQuantity(productId: String, quantity: Int) {
        cartService.updateQuantity(productId: productId, quantity: quantity)
    }
}

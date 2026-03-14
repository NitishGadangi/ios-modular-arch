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

    enum Action {
        case selectItem(productId: String)
        case tapCheckout
        case removeItem(productId: String)
        case updateQuantity(productId: String, quantity: Int)
    }

    enum State {
        case idle
        case updated(items: [CartItem], totalPrice: Double)
    }

    let actionHandler = PassthroughSubject<Action, Never>()
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }

    weak var navigationDelegate: CartViewModelNavigationDelegate?

    private var cartItems: [CartItem] = []
    private var totalPrice: Double = 0

    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(cartService: CartServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.cartService = cartService
        self.analytics = analytics

        bindCartService()
        bindActions()
    }

    private func bindCartService() {
        cartService.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.cartItems = items
                self.totalPrice = items.reduce(0) { $0 + $1.price * Double($1.quantity) }
                self.stateSubject.send(.updated(items: items, totalPrice: self.totalPrice))
            }
            .store(in: &cancellables)
    }

    private func bindActions() {
        actionHandler
            .sink { [weak self] action in self?.handleAction(action) }
            .store(in: &cancellables)
    }

    private func handleAction(_ action: Action) {
        switch action {
        case .selectItem(let productId):
            navigationDelegate?.cartViewModel(self, didRequest: .productSelected(id: productId))
        case .tapCheckout:
            analytics.track(AnalyticsEvent(name: "checkout_started", parameters: [
                "item_count": "\(cartItems.count)",
                "total": "\(totalPrice)"
            ]))
            navigationDelegate?.cartViewModel(self, didRequest: .checkoutTapped)
        case .removeItem(let productId):
            cartService.removeItem(productId: productId)
            analytics.track(AnalyticsEvent(name: "cart_item_removed", parameters: ["product_id": productId]))
        case .updateQuantity(let productId, let quantity):
            cartService.updateQuantity(productId: productId, quantity: quantity)
        }
    }
}

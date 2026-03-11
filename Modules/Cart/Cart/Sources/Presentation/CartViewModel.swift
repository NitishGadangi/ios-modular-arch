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

    struct Input {
        let selectItem = PassthroughSubject<String, Never>()
        let tapCheckout = PassthroughSubject<Void, Never>()
        let removeItem = PassthroughSubject<String, Never>()
        let updateQuantity = PassthroughSubject<(productId: String, quantity: Int), Never>()
    }

    struct Output {
        let cartItems: AnyPublisher<[CartItem], Never>
        let totalPrice: AnyPublisher<Double, Never>
    }

    let input = Input()
    let output: Output

    weak var navigationDelegate: CartViewModelNavigationDelegate?

    @Published private var cartItems: [CartItem] = []
    @Published private var totalPrice: Double = 0

    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(cartService: CartServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.cartService = cartService
        self.analytics = analytics

        self.output = Output(
            cartItems: _cartItems.projectedValue.eraseToAnyPublisher(),
            totalPrice: _totalPrice.projectedValue.eraseToAnyPublisher()
        )

        bindCartService()
        bindInputs()
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

    private func bindInputs() {
        input.selectItem
            .sink { [weak self] productId in
                self?.navigationDelegate?.cartViewModel(self!, didRequest: .productSelected(id: productId))
            }
            .store(in: &cancellables)

        input.tapCheckout
            .sink { [weak self] in
                guard let self else { return }
                self.analytics.track(AnalyticsEvent(name: "checkout_started", parameters: [
                    "item_count": "\(self.cartItems.count)",
                    "total": "\(self.totalPrice)"
                ]))
                self.navigationDelegate?.cartViewModel(self, didRequest: .checkoutTapped)
            }
            .store(in: &cancellables)

        input.removeItem
            .sink { [weak self] productId in
                self?.cartService.removeItem(productId: productId)
                self?.analytics.track(AnalyticsEvent(name: "cart_item_removed", parameters: ["product_id": productId]))
            }
            .store(in: &cancellables)

        input.updateQuantity
            .sink { [weak self] productId, quantity in
                self?.cartService.updateQuantity(productId: productId, quantity: quantity)
            }
            .store(in: &cancellables)
    }
}

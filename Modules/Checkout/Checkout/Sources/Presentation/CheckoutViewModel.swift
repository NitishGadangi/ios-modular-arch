import Foundation
import Combine
import CheckoutInterface
import CartInterface
import AnalyticsLib

protocol CheckoutViewModelNavigationDelegate: AnyObject {
    func checkoutViewModel(_ viewModel: CheckoutViewModel, didRequest event: CheckoutViewModel.NavigationEvent)
}

final class CheckoutViewModel {
    enum NavigationEvent {
        case orderCompleted
    }

    weak var navigationDelegate: CheckoutViewModelNavigationDelegate?

    @Published private(set) var cartItems: [CartItem] = []
    @Published private(set) var totalPrice: Double = 0
    @Published private(set) var isLoading = false
    @Published private(set) var orderSummary: OrderSummary?
    @Published private(set) var errorMessage: String?

    private let placeOrderUseCase: PlaceOrderUseCase
    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        placeOrderUseCase: PlaceOrderUseCase,
        cartService: CartServiceProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.placeOrderUseCase = placeOrderUseCase
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

    func placeOrder() {
        isLoading = true
        errorMessage = nil

        placeOrderUseCase.execute(total: totalPrice)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] summary in
                    self?.orderSummary = summary
                    self?.cartService.clearCart()
                    self?.analytics.track(AnalyticsEvent(
                        name: "order_placed",
                        parameters: [
                            "order_id": summary.orderId,
                            "total": "\(summary.total)"
                        ]
                    ))
                }
            )
            .store(in: &cancellables)
    }

    func goHome() {
        navigationDelegate?.checkoutViewModel(self, didRequest: .orderCompleted)
    }
}

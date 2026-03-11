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

    struct Input {
        let placeOrder = PassthroughSubject<Void, Never>()
        let goHome = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let cartItems: AnyPublisher<[CartItem], Never>
        let totalPrice: AnyPublisher<Double, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let orderSummary: AnyPublisher<OrderSummary?, Never>
        let errorMessage: AnyPublisher<String?, Never>
    }

    let input = Input()
    let output: Output

    weak var navigationDelegate: CheckoutViewModelNavigationDelegate?

    @Published private var cartItems: [CartItem] = []
    @Published private var totalPrice: Double = 0
    @Published private var isLoading = false
    @Published private var orderSummary: OrderSummary?
    @Published private var errorMessage: String?

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

        self.output = Output(
            cartItems: _cartItems.projectedValue.eraseToAnyPublisher(),
            totalPrice: _totalPrice.projectedValue.eraseToAnyPublisher(),
            isLoading: _isLoading.projectedValue.eraseToAnyPublisher(),
            orderSummary: _orderSummary.projectedValue.eraseToAnyPublisher(),
            errorMessage: _errorMessage.projectedValue.eraseToAnyPublisher()
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
        input.placeOrder
            .sink { [weak self] in self?.placeOrder() }
            .store(in: &cancellables)

        input.goHome
            .sink { [weak self] in self?.goHome() }
            .store(in: &cancellables)
    }

    private func placeOrder() {
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

    private func goHome() {
        navigationDelegate?.checkoutViewModel(self, didRequest: .orderCompleted)
    }
}

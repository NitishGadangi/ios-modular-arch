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

    enum Action {
        case placeOrder
        case goHome
    }

    enum State {
        case idle
        case cartLoaded(items: [CartItem], totalPrice: Double)
        case placingOrder(items: [CartItem], totalPrice: Double)
        case orderPlaced(OrderSummary)
        case error(String, items: [CartItem], totalPrice: Double)
    }

    let actionHandler = PassthroughSubject<Action, Never>()
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }

    weak var navigationDelegate: CheckoutViewModelNavigationDelegate?

    private var cartItems: [CartItem] = []
    private var totalPrice: Double = 0

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
        bindActions()
    }

    private func bindCartService() {
        cartService.items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                guard let self else { return }
                self.cartItems = items
                self.totalPrice = items.reduce(0) { $0 + $1.price * Double($1.quantity) }
                self.stateSubject.send(.cartLoaded(items: items, totalPrice: self.totalPrice))
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
        case .placeOrder:
            placeOrder()
        case .goHome:
            goHome()
        }
    }

    private func placeOrder() {
        stateSubject.send(.placingOrder(items: cartItems, totalPrice: totalPrice))

        placeOrderUseCase.execute(total: totalPrice)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    guard let self else { return }
                    if case .failure(let error) = completion {
                        self.stateSubject.send(.error(error.localizedDescription, items: self.cartItems, totalPrice: self.totalPrice))
                    }
                },
                receiveValue: { [weak self] summary in
                    self?.stateSubject.send(.orderPlaced(summary))
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

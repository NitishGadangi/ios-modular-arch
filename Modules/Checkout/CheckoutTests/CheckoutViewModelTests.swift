import XCTest
import Combine
import CheckoutInterface
import CartInterface
import AnalyticsLib
@testable import Checkout

final class CheckoutViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testPlaceOrderSetsOrderSummary() {
        let sut = makeSUT()

        let expectation = expectation(description: "Order placed")
        sut.statePublisher.sink { state in
            if case .orderPlaced(let order) = state {
                XCTAssertEqual(order.orderId, "ORD-1")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.actionHandler.send(.placeOrder)
        waitForExpectations(timeout: 2)
    }

    func testGoHomeCallsDelegate() {
        let sut = makeSUT()
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        sut.actionHandler.send(.goHome)

        if case .orderCompleted = spy.receivedEvents.first {} else {
            XCTFail("Expected orderCompleted event")
        }
    }

    private func makeSUT() -> CheckoutViewModel {
        let summary = OrderSummary(orderId: "ORD-1", status: "confirmed", total: 50.0, estimatedDelivery: "2024-03-20")
        let repo = StubCheckoutRepository(summary: summary)
        let useCase = PlaceOrderUseCase(repository: repo)
        return CheckoutViewModel(placeOrderUseCase: useCase, cartService: StubCartService(), analytics: StubAnalytics())
    }
}

private final class SpyNavDelegate: CheckoutViewModelNavigationDelegate {
    var receivedEvents: [CheckoutViewModel.NavigationEvent] = []

    func checkoutViewModel(_ viewModel: CheckoutViewModel, didRequest event: CheckoutViewModel.NavigationEvent) {
        receivedEvents.append(event)
    }
}

private final class StubCheckoutRepository: CheckoutRepositoryProtocol {
    let summary: OrderSummary
    init(summary: OrderSummary) { self.summary = summary }
    func placeOrder(total: Double) -> AnyPublisher<OrderSummary, Error> {
        Just(summary).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class StubCartService: CartServiceProtocol {
    let items = CurrentValueSubject<[CartItem], Never>([])
    var totalPrice: Double { 0 }
    func addItem(_ item: CartItem) {}
    func removeItem(productId: String) {}
    func updateQuantity(productId: String, quantity: Int) {}
    func clearCart() { items.send([]) }
}

private final class StubAnalytics: AnalyticsServiceProtocol {
    var trackedEvents: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { trackedEvents.append(event) }
    func flush() {}
}

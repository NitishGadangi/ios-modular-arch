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
        let summary = OrderSummary(orderId: "ORD-1", status: "confirmed", total: 50.0, estimatedDelivery: "2024-03-20")
        let repo = StubCheckoutRepository(summary: summary)
        let useCase = PlaceOrderUseCase(repository: repo)
        let cart = StubCartService()
        let analytics = StubAnalytics()
        let sut = CheckoutViewModel(placeOrderUseCase: useCase, cartService: cart, analytics: analytics)

        let expectation = expectation(description: "Order placed")
        sut.$orderSummary.compactMap { $0 }.sink { order in
            XCTAssertEqual(order.orderId, "ORD-1")
            expectation.fulfill()
        }.store(in: &cancellables)

        sut.placeOrder()
        waitForExpectations(timeout: 2)
    }

    func testGoHomeEmitsNavigation() {
        let summary = OrderSummary(orderId: "ORD-1", status: "confirmed", total: 50.0, estimatedDelivery: "2024-03-20")
        let repo = StubCheckoutRepository(summary: summary)
        let useCase = PlaceOrderUseCase(repository: repo)
        let cart = StubCartService()
        let analytics = StubAnalytics()
        let sut = CheckoutViewModel(placeOrderUseCase: useCase, cartService: cart, analytics: analytics)

        let expectation = expectation(description: "Nav event")
        sut.navigation.sink { event in
            if case .orderCompleted = event { expectation.fulfill() }
        }.store(in: &cancellables)

        sut.goHome()
        waitForExpectations(timeout: 1)
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

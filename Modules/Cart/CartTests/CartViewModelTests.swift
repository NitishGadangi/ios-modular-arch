import XCTest
import Combine
import CartInterface
import AnalyticsLib
@testable import Cart

final class CartViewModelTests: XCTestCase {
    var sut: CartViewModel!
    var mockCartService: MockCartService!
    var mockAnalytics: MockAnalyticsService!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockCartService = MockCartService()
        mockAnalytics = MockAnalyticsService()
        sut = CartViewModel(cartService: mockCartService, analytics: mockAnalytics)
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        mockAnalytics = nil
        mockCartService = nil
        super.tearDown()
    }

    func testNavigationEventOnProductSelected() {
        let expectation = expectation(description: "Nav event")

        sut.navigation.sink { event in
            if case .productSelected(let id) = event {
                XCTAssertEqual(id, "1")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.didSelectItem(productId: "1")
        waitForExpectations(timeout: 1)
    }

    func testNavigationEventOnCheckout() {
        let expectation = expectation(description: "Checkout event")

        sut.navigation.sink { event in
            if case .checkoutTapped = event {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.didTapCheckout()
        waitForExpectations(timeout: 1)
    }

    func testCheckoutTracksAnalytics() {
        sut.didTapCheckout()
        XCTAssertTrue(mockAnalytics.trackedEvents.contains(where: { $0.name == "checkout_started" }))
    }

    func testRemoveTracksAnalytics() {
        sut.removeItem(productId: "1")
        XCTAssertTrue(mockAnalytics.trackedEvents.contains(where: { $0.name == "cart_item_removed" }))
    }
}

// MARK: - Mocks

final class MockCartService: CartServiceProtocol {
    let items = CurrentValueSubject<[CartItem], Never>([])
    var totalPrice: Double { items.value.reduce(0) { $0 + $1.price * Double($1.quantity) } }

    func addItem(_ item: CartItem) {
        var current = items.value
        current.append(item)
        items.send(current)
    }

    func removeItem(productId: String) {
        var current = items.value
        current.removeAll { $0.productId == productId }
        items.send(current)
    }

    func updateQuantity(productId: String, quantity: Int) {}
    func clearCart() { items.send([]) }
}

final class MockAnalyticsService: AnalyticsServiceProtocol {
    var trackedEvents: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { trackedEvents.append(event) }
    func flush() {}
}

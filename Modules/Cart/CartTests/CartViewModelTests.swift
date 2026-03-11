import XCTest
import Combine
import CartInterface
import AnalyticsLib
@testable import Cart

final class CartViewModelTests: XCTestCase {
    var sut: CartViewModel!
    var mockCartService: MockCartService!
    var mockAnalytics: MockAnalyticsService!

    override func setUp() {
        super.setUp()
        mockCartService = MockCartService()
        mockAnalytics = MockAnalyticsService()
        sut = CartViewModel(cartService: mockCartService, analytics: mockAnalytics)
    }

    override func tearDown() {
        sut = nil
        mockAnalytics = nil
        mockCartService = nil
        super.tearDown()
    }

    func testNavigationOnProductSelected() {
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        sut.input.selectItem.send("1")

        if case .productSelected(let id) = spy.receivedEvents.first {
            XCTAssertEqual(id, "1")
        } else {
            XCTFail("Expected productSelected event")
        }
    }

    func testNavigationOnCheckout() {
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        sut.input.tapCheckout.send()

        if case .checkoutTapped = spy.receivedEvents.first {} else {
            XCTFail("Expected checkoutTapped event")
        }
    }

    func testCheckoutTracksAnalytics() {
        sut.input.tapCheckout.send()
        XCTAssertTrue(mockAnalytics.trackedEvents.contains(where: { $0.name == "checkout_started" }))
    }

    func testRemoveTracksAnalytics() {
        sut.input.removeItem.send("1")
        XCTAssertTrue(mockAnalytics.trackedEvents.contains(where: { $0.name == "cart_item_removed" }))
    }
}

private final class SpyNavDelegate: CartViewModelNavigationDelegate {
    var receivedEvents: [CartViewModel.NavigationEvent] = []

    func cartViewModel(_ viewModel: CartViewModel, didRequest event: CartViewModel.NavigationEvent) {
        receivedEvents.append(event)
    }
}

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

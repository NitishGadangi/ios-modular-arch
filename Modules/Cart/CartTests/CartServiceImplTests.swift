import XCTest
import Combine
import CartInterface
@testable import Cart

final class CartServiceImplTests: XCTestCase {
    var sut: CartServiceImpl!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = CartServiceImpl()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        sut = nil
        super.tearDown()
    }

    func testAddItem() {
        let item = CartItem(productId: "1", name: "Test", price: 10.0, quantity: 1)
        sut.addItem(item)
        XCTAssertEqual(sut.items.value.count, 1)
        XCTAssertEqual(sut.items.value.first?.productId, "1")
    }

    func testAddSameItemIncreasesQuantity() {
        let item = CartItem(productId: "1", name: "Test", price: 10.0, quantity: 1)
        sut.addItem(item)
        sut.addItem(item)
        XCTAssertEqual(sut.items.value.count, 1)
        XCTAssertEqual(sut.items.value.first?.quantity, 2)
    }

    func testRemoveItem() {
        let item = CartItem(productId: "1", name: "Test", price: 10.0, quantity: 1)
        sut.addItem(item)
        sut.removeItem(productId: "1")
        XCTAssertTrue(sut.items.value.isEmpty)
    }

    func testUpdateQuantity() {
        let item = CartItem(productId: "1", name: "Test", price: 10.0, quantity: 1)
        sut.addItem(item)
        sut.updateQuantity(productId: "1", quantity: 5)
        XCTAssertEqual(sut.items.value.first?.quantity, 5)
    }

    func testUpdateQuantityToZeroRemovesItem() {
        let item = CartItem(productId: "1", name: "Test", price: 10.0, quantity: 1)
        sut.addItem(item)
        sut.updateQuantity(productId: "1", quantity: 0)
        XCTAssertTrue(sut.items.value.isEmpty)
    }

    func testTotalPrice() {
        sut.addItem(CartItem(productId: "1", name: "A", price: 10.0, quantity: 2))
        sut.addItem(CartItem(productId: "2", name: "B", price: 5.0, quantity: 3))
        XCTAssertEqual(sut.totalPrice, 35.0, accuracy: 0.01)
    }

    func testClearCart() {
        sut.addItem(CartItem(productId: "1", name: "Test", price: 10.0, quantity: 1))
        sut.clearCart()
        XCTAssertTrue(sut.items.value.isEmpty)
    }

    func testItemsPublisherEmitsUpdates() {
        let expectation = expectation(description: "Items updated")
        var receivedItems: [[CartItem]] = []

        sut.items
            .dropFirst()
            .sink { items in
                receivedItems.append(items)
                if receivedItems.count == 2 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        sut.addItem(CartItem(productId: "1", name: "A", price: 10.0, quantity: 1))
        sut.addItem(CartItem(productId: "2", name: "B", price: 5.0, quantity: 1))

        waitForExpectations(timeout: 1)
        XCTAssertEqual(receivedItems.last?.count, 2)
    }
}

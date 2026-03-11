import XCTest
@testable import NetworkLib

final class MockNetworkServiceTests: XCTestCase {
    var sut: MockNetworkService!

    override func setUp() {
        super.setUp()
        sut = MockNetworkService()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testDecodeProducts() {
        let expectation = expectation(description: "Products decoded")
        let endpoint = Endpoint(path: "/products")

        let cancellable = sut.request(endpoint, responseType: [TestProduct].self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                },
                receiveValue: { products in
                    XCTAssertFalse(products.isEmpty)
                    XCTAssertEqual(products.first?.name, "Wireless Headphones")
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 2)
        _ = cancellable
    }

    func testDecodeProductDetail() {
        let expectation = expectation(description: "Product detail decoded")
        let endpoint = Endpoint(path: "/products/1")

        let cancellable = sut.request(endpoint, responseType: TestProductDetail.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                },
                receiveValue: { detail in
                    XCTAssertEqual(detail.id, "1")
                    XCTAssertEqual(detail.rating, 4.5)
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 2)
        _ = cancellable
    }

    func testInvalidEndpointReturnsError() {
        let expectation = expectation(description: "Error returned")
        let endpoint = Endpoint(path: "/nonexistent")

        let cancellable = sut.request(endpoint, responseType: TestProduct.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        expectation.fulfill()
                    }
                },
                receiveValue: { _ in
                    XCTFail("Should not receive value")
                }
            )

        waitForExpectations(timeout: 2)
        _ = cancellable
    }
}

// Test models
private struct TestProduct: Decodable {
    let id: String
    let name: String
    let price: Double
    let imageUrl: String
    let description: String
}

private struct TestProductDetail: Decodable {
    let id: String
    let name: String
    let price: Double
    let rating: Double
    let reviewCount: Int
}

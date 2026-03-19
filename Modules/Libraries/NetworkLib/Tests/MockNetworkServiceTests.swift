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
        let endpoint = MockEndpoint.products

        let cancellable = sut.request(endpoint, responseType: [TestProduct].self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                },
                receiveValue: { products in
                    XCTAssertFalse(products.isEmpty)
                    XCTAssertEqual(products.first?.title, "Wireless Headphones")
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 2)
        _ = cancellable
    }

    func testDecodeProductDetail() {
        let expectation = expectation(description: "Product detail decoded")
        let endpoint = MockEndpoint.productDetail(id: "1")

        let cancellable = sut.request(endpoint, responseType: TestProductDetail.self)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        XCTFail("Unexpected error: \(error)")
                    }
                },
                receiveValue: { detail in
                    XCTAssertEqual(detail.id, 1)
                    XCTAssertEqual(detail.rating.rate, 4.5)
                    expectation.fulfill()
                }
            )

        waitForExpectations(timeout: 2)
        _ = cancellable
    }

    func testInvalidEndpointReturnsError() {
        let expectation = expectation(description: "Error returned")
        let endpoint = TestEndpoint(path: "/nonexistent")

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

// Test helpers
private struct TestEndpoint: Endpoint {
    let baseURL: String = ""
    let path: String
    let method: HTTPMethod = .get
    let queryParams: [String: String]? = nil
}

// Test models
private struct TestProduct: Decodable {
    let id: Int
    let title: String
    let price: Double
    let image: String
    let category: String
    let rating: TestRating
}

private struct TestProductDetail: Decodable {
    let id: Int
    let title: String
    let price: Double
    let rating: TestRating
}

private struct TestRating: Decodable {
    let rate: Double
    let count: Int
}

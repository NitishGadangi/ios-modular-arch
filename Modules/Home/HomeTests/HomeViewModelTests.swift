import XCTest
import Combine
import HomeInterface
import AnalyticsLib
@testable import Home

final class HomeViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testNavigationEventOnProductSelected() {
        let mockAnalytics = MockAnalytics()
        let repo = StubHomeRepository(products: [])
        let useCase = GetProductsUseCase(repository: repo)
        let sut = HomeViewModel(getProductsUseCase: useCase, analytics: mockAnalytics)

        let expectation = expectation(description: "Nav event")
        sut.navigation.sink { event in
            if case .productSelected(let id) = event {
                XCTAssertEqual(id, "42")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.didSelectProduct(id: "42")
        waitForExpectations(timeout: 1)
    }

    func testNavigationEventOnCartTapped() {
        let mockAnalytics = MockAnalytics()
        let repo = StubHomeRepository(products: [])
        let useCase = GetProductsUseCase(repository: repo)
        let sut = HomeViewModel(getProductsUseCase: useCase, analytics: mockAnalytics)

        let expectation = expectation(description: "Cart event")
        sut.navigation.sink { event in
            if case .cartTapped = event {
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.didTapCart()
        waitForExpectations(timeout: 1)
    }

    func testLoadProductsSetsProducts() {
        let products = [
            ProductSummary(id: "1", name: "Test", price: 9.99, imageUrl: "img", description: "desc")
        ]
        let mockAnalytics = MockAnalytics()
        let repo = StubHomeRepository(products: products)
        let useCase = GetProductsUseCase(repository: repo)
        let sut = HomeViewModel(getProductsUseCase: useCase, analytics: mockAnalytics)

        let expectation = expectation(description: "Products loaded")
        sut.$products.dropFirst().sink { loadedProducts in
            XCTAssertEqual(loadedProducts.count, 1)
            XCTAssertEqual(loadedProducts.first?.name, "Test")
            expectation.fulfill()
        }.store(in: &cancellables)

        sut.loadProducts()
        waitForExpectations(timeout: 2)
    }
}

private final class StubHomeRepository: HomeRepositoryProtocol {
    let products: [ProductSummary]

    init(products: [ProductSummary]) {
        self.products = products
    }

    func fetchProducts() -> AnyPublisher<[ProductSummary], Error> {
        Just(products)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
}

private final class MockAnalytics: AnalyticsServiceProtocol {
    var trackedEvents: [AnalyticsEvent] = []
    func track(_ event: AnalyticsEvent) { trackedEvents.append(event) }
    func flush() {}
}

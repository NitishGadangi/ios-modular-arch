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

    func testNavigationOnProductSelected() {
        let sut = makeSUT()
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        sut.actionHandler.send(.selectProduct(id: "42"))

        XCTAssertEqual(spy.receivedEvents.count, 1)
        if case .productSelected(let id) = spy.receivedEvents.first {
            XCTAssertEqual(id, "42")
        } else {
            XCTFail("Expected productSelected event")
        }
    }

    func testNavigationOnCartTapped() {
        let sut = makeSUT()
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        sut.actionHandler.send(.tapCart)

        XCTAssertEqual(spy.receivedEvents.count, 1)
        if case .cartTapped = spy.receivedEvents.first {} else {
            XCTFail("Expected cartTapped event")
        }
    }

    func testLoadProductsSetsProducts() {
        let products = [
            ProductSummary(id: "1", name: "Test", price: 9.99, imageUrl: "img", description: "desc")
        ]
        let sut = makeSUT(products: products)

        let expectation = expectation(description: "Products loaded")
        sut.statePublisher.sink { state in
            if case .loaded(let loadedProducts) = state {
                XCTAssertEqual(loadedProducts.count, 1)
                XCTAssertEqual(loadedProducts.first?.name, "Test")
                expectation.fulfill()
            }
        }.store(in: &cancellables)

        sut.actionHandler.send(.loadProducts)
        waitForExpectations(timeout: 2)
    }

    private func makeSUT(products: [ProductSummary] = []) -> HomeViewModel {
        let repo = StubHomeRepository(products: products)
        let useCase = GetProductsUseCase(repository: repo)
        return HomeViewModel(getProductsUseCase: useCase, analytics: StubAnalytics())
    }
}

private final class SpyNavDelegate: HomeViewModelNavigationDelegate {
    var receivedEvents: [HomeViewModel.NavigationEvent] = []

    func homeViewModel(_ viewModel: HomeViewModel, didRequest event: HomeViewModel.NavigationEvent) {
        receivedEvents.append(event)
    }
}

private final class StubHomeRepository: HomeRepositoryProtocol {
    let products: [ProductSummary]
    init(products: [ProductSummary]) { self.products = products }

    func fetchProducts() -> AnyPublisher<[ProductSummary], Error> {
        Just(products).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class StubAnalytics: AnalyticsServiceProtocol {
    var isEnabled: Bool = true
    func setEnabled(_ enabled: Bool) { isEnabled = enabled }
    func track(_ event: AnalyticsEvent) {}
    func flush() {}
}

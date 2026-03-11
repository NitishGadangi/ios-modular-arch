import XCTest
import Combine
import DetailsInterface
import CartInterface
import AnalyticsLib
@testable import Details

final class DetailsViewModelTests: XCTestCase {
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        cancellables = []
    }

    override func tearDown() {
        cancellables = nil
        super.tearDown()
    }

    func testLoadProductSetsProduct() {
        let sut = makeSUT()

        let expectation = expectation(description: "Product loaded")
        sut.$product.compactMap { $0 }.sink { product in
            XCTAssertEqual(product.name, "Test")
            expectation.fulfill()
        }.store(in: &cancellables)

        sut.loadProduct()
        waitForExpectations(timeout: 2)
    }

    func testBuyNowCallsDelegate() {
        let sut = makeSUT()
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        let loadExp = expectation(description: "loaded")
        sut.$product.compactMap { $0 }.sink { _ in loadExp.fulfill() }.store(in: &cancellables)
        sut.loadProduct()
        waitForExpectations(timeout: 2)

        sut.buyNow()

        XCTAssertEqual(spy.receivedEvents.count, 1)
        if case .buyNow = spy.receivedEvents.first {} else {
            XCTFail("Expected buyNow event")
        }
    }

    func testCartTappedCallsDelegate() {
        let sut = makeSUT()
        let spy = SpyNavDelegate()
        sut.navigationDelegate = spy

        sut.didTapCart()

        if case .cartTapped = spy.receivedEvents.first {} else {
            XCTFail("Expected cartTapped event")
        }
    }

    private func makeSUT() -> DetailsViewModel {
        let detail = ProductDetail(
            id: "1", name: "Test", price: 29.99, imageUrl: "img",
            description: "desc", specs: ["Spec1"], rating: 4.0, reviewCount: 10
        )
        let repo = StubDetailsRepository(detail: detail)
        let useCase = GetProductDetailUseCase(repository: repo)
        return DetailsViewModel(
            productId: "1",
            getProductDetailUseCase: useCase,
            cartService: StubCartService(),
            analytics: StubAnalytics()
        )
    }
}

private final class SpyNavDelegate: DetailsViewModelNavigationDelegate {
    var receivedEvents: [DetailsViewModel.NavigationEvent] = []

    func detailsViewModel(_ viewModel: DetailsViewModel, didRequest event: DetailsViewModel.NavigationEvent) {
        receivedEvents.append(event)
    }
}

private final class StubDetailsRepository: DetailsRepositoryProtocol {
    let detail: ProductDetail
    init(detail: ProductDetail) { self.detail = detail }
    func fetchProductDetail(id: String) -> AnyPublisher<ProductDetail, Error> {
        Just(detail).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}

private final class StubCartService: CartServiceProtocol {
    let items = CurrentValueSubject<[CartItem], Never>([])
    var totalPrice: Double { 0 }
    func addItem(_ item: CartItem) {}
    func removeItem(productId: String) {}
    func updateQuantity(productId: String, quantity: Int) {}
    func clearCart() {}
}

private final class StubAnalytics: AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent) {}
    func flush() {}
}

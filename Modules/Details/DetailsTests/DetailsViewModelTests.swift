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
        let detail = ProductDetail(
            id: "1", name: "Test", price: 29.99, imageUrl: "img",
            description: "desc", specs: ["Spec1"], rating: 4.0, reviewCount: 10
        )
        let repo = StubDetailsRepository(detail: detail)
        let useCase = GetProductDetailUseCase(repository: repo)
        let cart = StubCartService()
        let analytics = StubAnalytics()
        let sut = DetailsViewModel(
            productId: "1",
            getProductDetailUseCase: useCase,
            cartService: cart,
            analytics: analytics
        )

        let expectation = expectation(description: "Product loaded")
        sut.$product.compactMap { $0 }.sink { product in
            XCTAssertEqual(product.name, "Test")
            expectation.fulfill()
        }.store(in: &cancellables)

        sut.loadProduct()
        waitForExpectations(timeout: 2)
    }

    func testBuyNowEmitsNavigation() {
        let detail = ProductDetail(
            id: "1", name: "Test", price: 29.99, imageUrl: "img",
            description: "desc", specs: [], rating: 4.0, reviewCount: 10
        )
        let repo = StubDetailsRepository(detail: detail)
        let useCase = GetProductDetailUseCase(repository: repo)
        let cart = StubCartService()
        let analytics = StubAnalytics()
        let sut = DetailsViewModel(
            productId: "1",
            getProductDetailUseCase: useCase,
            cartService: cart,
            analytics: analytics
        )

        // Load product first so buyNow has something to add
        let loadExp = expectation(description: "loaded")
        sut.$product.compactMap { $0 }.sink { _ in loadExp.fulfill() }.store(in: &cancellables)
        sut.loadProduct()
        waitForExpectations(timeout: 2)

        let navExp = expectation(description: "Nav event")
        sut.navigation.sink { event in
            if case .buyNow = event { navExp.fulfill() }
        }.store(in: &cancellables)

        sut.buyNow()
        waitForExpectations(timeout: 1)
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

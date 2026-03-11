import Foundation
import Combine
import DetailsInterface
import CartInterface
import AnalyticsLib

protocol DetailsViewModelNavigationDelegate: AnyObject {
    func detailsViewModel(_ viewModel: DetailsViewModel, didRequest event: DetailsViewModel.NavigationEvent)
}

final class DetailsViewModel {
    enum NavigationEvent {
        case buyNow
        case cartTapped
    }

    weak var navigationDelegate: DetailsViewModelNavigationDelegate?

    @Published private(set) var product: ProductDetail?
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    @Published private(set) var addedToCart = false

    private let productId: String
    private let getProductDetailUseCase: GetProductDetailUseCase
    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(
        productId: String,
        getProductDetailUseCase: GetProductDetailUseCase,
        cartService: CartServiceProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.productId = productId
        self.getProductDetailUseCase = getProductDetailUseCase
        self.cartService = cartService
        self.analytics = analytics
    }

    func loadProduct() {
        isLoading = true
        errorMessage = nil

        getProductDetailUseCase.execute(productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] detail in
                    self?.product = detail
                    self?.analytics.track(AnalyticsEvent(
                        name: "product_viewed",
                        parameters: ["product_id": detail.id, "product_name": detail.name]
                    ))
                }
            )
            .store(in: &cancellables)
    }

    func addToCart() {
        guard let product = product else { return }
        let item = CartItem(
            productId: product.id,
            name: product.name,
            price: product.price,
            quantity: 1
        )
        cartService.addItem(item)
        addedToCart = true
        analytics.track(AnalyticsEvent(name: "add_to_cart", parameters: [
            "product_id": product.id,
            "price": "\(product.price)"
        ]))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.addedToCart = false
        }
    }

    func buyNow() {
        addToCart()
        analytics.track(AnalyticsEvent(name: "buy_now_tapped", parameters: ["product_id": productId]))
        navigationDelegate?.detailsViewModel(self, didRequest: .buyNow)
    }

    func didTapCart() {
        navigationDelegate?.detailsViewModel(self, didRequest: .cartTapped)
    }
}

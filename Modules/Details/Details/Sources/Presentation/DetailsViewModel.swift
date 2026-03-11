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

    struct Input {
        let loadProduct = PassthroughSubject<Void, Never>()
        let addToCart = PassthroughSubject<Void, Never>()
        let buyNow = PassthroughSubject<Void, Never>()
        let tapCart = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let product: AnyPublisher<ProductDetail?, Never>
        let isLoading: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<String?, Never>
        let addedToCart: AnyPublisher<Bool, Never>
    }

    let input = Input()
    let output: Output

    weak var navigationDelegate: DetailsViewModelNavigationDelegate?

    @Published private var product: ProductDetail?
    @Published private var isLoading = false
    @Published private var errorMessage: String?
    @Published private var addedToCart = false

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

        self.output = Output(
            product: _product.projectedValue.eraseToAnyPublisher(),
            isLoading: _isLoading.projectedValue.eraseToAnyPublisher(),
            errorMessage: _errorMessage.projectedValue.eraseToAnyPublisher(),
            addedToCart: _addedToCart.projectedValue.eraseToAnyPublisher()
        )

        bindInputs()
    }

    private func bindInputs() {
        input.loadProduct
            .sink { [weak self] in self?.loadProduct() }
            .store(in: &cancellables)

        input.addToCart
            .sink { [weak self] in self?.addToCart() }
            .store(in: &cancellables)

        input.buyNow
            .sink { [weak self] in self?.buyNow() }
            .store(in: &cancellables)

        input.tapCart
            .sink { [weak self] in self?.didTapCart() }
            .store(in: &cancellables)
    }

    private func loadProduct() {
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

    private func addToCart() {
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

    private func buyNow() {
        addToCart()
        analytics.track(AnalyticsEvent(name: "buy_now_tapped", parameters: ["product_id": productId]))
        navigationDelegate?.detailsViewModel(self, didRequest: .buyNow)
    }

    private func didTapCart() {
        navigationDelegate?.detailsViewModel(self, didRequest: .cartTapped)
    }
}

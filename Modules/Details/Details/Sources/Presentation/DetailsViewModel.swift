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

    enum Action {
        case loadProduct
        case addToCart
        case buyNow
        case tapCart
    }

    enum State {
        case idle
        case loading
        case loaded(ProductDetail)
        case addedToCart(product: ProductDetail)
        case error(String)
    }

    let actionHandler = PassthroughSubject<Action, Never>()
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }

    weak var navigationDelegate: DetailsViewModelNavigationDelegate?

    private var currentProduct: ProductDetail?

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

        bindActions()
    }

    private func bindActions() {
        actionHandler
            .sink { [weak self] action in self?.handleAction(action) }
            .store(in: &cancellables)
    }

    private func handleAction(_ action: Action) {
        switch action {
        case .loadProduct:
            loadProduct()
        case .addToCart:
            addToCart()
        case .buyNow:
            buyNow()
        case .tapCart:
            didTapCart()
        }
    }

    private func loadProduct() {
        stateSubject.send(.loading)

        getProductDetailUseCase.execute(productId: productId)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.stateSubject.send(.error(error.localizedDescription))
                    }
                },
                receiveValue: { [weak self] detail in
                    self?.currentProduct = detail
                    self?.stateSubject.send(.loaded(detail))
                    self?.analytics.track(AnalyticsEvent(
                        name: "product_viewed",
                        parameters: ["product_id": String(detail.id), "product_name": detail.title]
                    ))
                }
            )
            .store(in: &cancellables)
    }

    private func addToCart() {
        guard let product = currentProduct else { return }
        let item = CartItem(
            productId: String(product.id),
            name: product.title,
            price: product.price,
            quantity: 1,
            imageURL: product.image
        )
        cartService.addItem(item)
        stateSubject.send(.addedToCart(product: product))
        analytics.track(AnalyticsEvent(name: "add_to_cart", parameters: [
            "product_id": String(product.id),
            "price": "\(product.price)"
        ]))

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self, let product = self.currentProduct else { return }
            self.stateSubject.send(.loaded(product))
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

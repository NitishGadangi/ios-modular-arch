import Foundation
import Combine
import HomeInterface
import AnalyticsLib

protocol HomeViewModelNavigationDelegate: AnyObject {
    func homeViewModel(_ viewModel: HomeViewModel, didRequest event: HomeViewModel.NavigationEvent)
}

final class HomeViewModel {
    enum NavigationEvent {
        case productSelected(id: String)
        case cartTapped
    }

    struct Input {
        let loadProducts = PassthroughSubject<Void, Never>()
        let selectProduct = PassthroughSubject<String, Never>()
        let tapCart = PassthroughSubject<Void, Never>()
    }

    struct Output {
        let products: AnyPublisher<[ProductSummary], Never>
        let isLoading: AnyPublisher<Bool, Never>
        let errorMessage: AnyPublisher<String?, Never>
    }

    let input = Input()
    let output: Output

    weak var navigationDelegate: HomeViewModelNavigationDelegate?

    @Published private var products: [ProductSummary] = []
    @Published private var isLoading = false
    @Published private var errorMessage: String?

    private let getProductsUseCase: GetProductsUseCase
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(getProductsUseCase: GetProductsUseCase, analytics: AnalyticsServiceProtocol) {
        self.getProductsUseCase = getProductsUseCase
        self.analytics = analytics

        self.output = Output(
            products: _products.projectedValue.eraseToAnyPublisher(),
            isLoading: _isLoading.projectedValue.eraseToAnyPublisher(),
            errorMessage: _errorMessage.projectedValue.eraseToAnyPublisher()
        )

        bindInputs()
    }

    private func bindInputs() {
        input.loadProducts
            .sink { [weak self] in self?.loadProducts() }
            .store(in: &cancellables)

        input.selectProduct
            .sink { [weak self] id in self?.didSelectProduct(id: id) }
            .store(in: &cancellables)

        input.tapCart
            .sink { [weak self] in self?.didTapCart() }
            .store(in: &cancellables)
    }

    private func loadProducts() {
        isLoading = true
        errorMessage = nil

        getProductsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = error.localizedDescription
                    }
                },
                receiveValue: { [weak self] products in
                    self?.products = products
                    self?.analytics.track(AnalyticsEvent(
                        name: "products_loaded",
                        parameters: ["count": "\(products.count)"]
                    ))
                }
            )
            .store(in: &cancellables)
    }

    private func didSelectProduct(id: String) {
        analytics.track(AnalyticsEvent(name: "product_tapped", parameters: ["product_id": id]))
        navigationDelegate?.homeViewModel(self, didRequest: .productSelected(id: id))
    }

    private func didTapCart() {
        navigationDelegate?.homeViewModel(self, didRequest: .cartTapped)
    }
}

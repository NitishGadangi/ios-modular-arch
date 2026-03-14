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

    enum Action {
        case loadProducts
        case selectProduct(id: String)
        case tapCart
    }

    enum State {
        case idle
        case loading
        case loaded(products: [ProductSummary])
        case error(String)
    }

    let actionHandler = PassthroughSubject<Action, Never>()
    private let stateSubject = CurrentValueSubject<State, Never>(.idle)
    var statePublisher: AnyPublisher<State, Never> { stateSubject.eraseToAnyPublisher() }

    weak var navigationDelegate: HomeViewModelNavigationDelegate?

    private let getProductsUseCase: GetProductsUseCase
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(getProductsUseCase: GetProductsUseCase, analytics: AnalyticsServiceProtocol) {
        self.getProductsUseCase = getProductsUseCase
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
        case .loadProducts:
            loadProducts()
        case .selectProduct(let id):
            didSelectProduct(id: id)
        case .tapCart:
            didTapCart()
        }
    }

    private func loadProducts() {
        stateSubject.send(.loading)

        getProductsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        self?.stateSubject.send(.error(error.localizedDescription))
                    }
                },
                receiveValue: { [weak self] products in
                    self?.stateSubject.send(.loaded(products: products))
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

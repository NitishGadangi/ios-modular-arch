import UIKit
import Combine
import HomeInterface
import SharedRouterInterface
import NetworkLib
import AnalyticsLib

public final class HomeCoordinator: HomeBuildable {
    private let router: SharedRouterProtocol
    private let networkService: NetworkServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(router: SharedRouterProtocol, networkService: NetworkServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.router = router
        self.networkService = networkService
        self.analytics = analytics
    }

    public func buildHomeScreen() -> UIViewController {
        let repository = HomeRepository(networkService: networkService)
        let useCase = GetProductsUseCase(repository: repository)
        let viewModel = HomeViewModel(getProductsUseCase: useCase, analytics: analytics)

        viewModel.navigation.sink { [weak self] event in
            switch event {
            case .productSelected(let id):
                self?.router.navigate(to: .productDetail(productId: id), style: .push)
            case .cartTapped:
                self?.router.navigate(to: .cart, style: .push)
            }
        }.store(in: &cancellables)

        return HomeViewController(viewModel: viewModel)
    }
}

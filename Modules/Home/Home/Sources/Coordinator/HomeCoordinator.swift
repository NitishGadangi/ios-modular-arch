import UIKit
import HomeInterface
import SharedRouterInterface
import NetworkLib
import AnalyticsLib

public final class HomeCoordinator: HomeBuildable {
    private let router: SharedRouterProtocol
    private let networkService: NetworkServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    public init(router: SharedRouterProtocol, networkService: NetworkServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.router = router
        self.networkService = networkService
        self.analytics = analytics
    }

    public func buildHomeScreen() -> UIViewController {
        let repository = HomeRepository(networkService: networkService)
        let useCase = GetProductsUseCase(repository: repository)
        let viewModel = HomeViewModel(getProductsUseCase: useCase, analytics: analytics)
        viewModel.navigationDelegate = self
        return HomeViewController(viewModel: viewModel)
    }
}

extension HomeCoordinator: HomeViewModelNavigationDelegate {
    func homeViewModel(_ viewModel: HomeViewModel, didRequest event: HomeViewModel.NavigationEvent) {
        switch event {
        case .productSelected(let id):
            router.navigate(to: .productDetail(productId: id), style: .push)
        case .cartTapped:
            router.navigate(to: .cart, style: .push)
        }
    }
}

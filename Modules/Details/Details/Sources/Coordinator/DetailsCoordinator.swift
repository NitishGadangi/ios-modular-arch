import UIKit
import DetailsInterface
import CartInterface
import SharedRouterInterface
import NetworkLib
import AnalyticsLib

public final class DetailsCoordinator: DetailsBuildable {
    private let router: SharedRouterProtocol
    private let networkService: NetworkServiceProtocol
    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    public init(
        router: SharedRouterProtocol,
        networkService: NetworkServiceProtocol,
        cartService: CartServiceProtocol,
        analytics: AnalyticsServiceProtocol
    ) {
        self.router = router
        self.networkService = networkService
        self.cartService = cartService
        self.analytics = analytics
    }

    public func buildDetailsScreen(productId: String) -> UIViewController {
        let repository = DetailsRepository(networkService: networkService)
        let useCase = GetProductDetailUseCase(repository: repository)
        let viewModel = DetailsViewModel(
            productId: productId,
            getProductDetailUseCase: useCase,
            cartService: cartService,
            analytics: analytics
        )
        viewModel.navigationDelegate = self
        return DetailsViewController(viewModel: viewModel)
    }
}

extension DetailsCoordinator: DetailsViewModelNavigationDelegate {
    func detailsViewModel(_ viewModel: DetailsViewModel, didRequest event: DetailsViewModel.NavigationEvent) {
        switch event {
        case .buyNow:
            router.navigate(to: .checkout, style: .push)
        case .cartTapped:
            router.navigate(to: .cart, style: .push)
        }
    }
}

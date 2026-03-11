import UIKit
import Combine
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
    private var cancellables = Set<AnyCancellable>()

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

        viewModel.navigation.sink { [weak self] event in
            switch event {
            case .buyNow:
                self?.router.navigate(to: .checkout, style: .push)
            }
        }.store(in: &cancellables)

        return DetailsViewController(viewModel: viewModel)
    }
}

import UIKit
import CheckoutInterface
import CartInterface
import SharedRouterInterface
import NetworkLib
import AnalyticsLib

public final class CheckoutCoordinator: CheckoutBuildable {
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

    public func buildCheckoutScreen() -> UIViewController {
        let repository = CheckoutRepository(networkService: networkService)
        let useCase = PlaceOrderUseCase(repository: repository)
        let viewModel = CheckoutViewModel(
            placeOrderUseCase: useCase,
            cartService: cartService,
            analytics: analytics
        )
        viewModel.navigationDelegate = self
        return CheckoutViewController(viewModel: viewModel)
    }
}

extension CheckoutCoordinator: CheckoutViewModelNavigationDelegate {
    func checkoutViewModel(_ viewModel: CheckoutViewModel, didRequest event: CheckoutViewModel.NavigationEvent) {
        switch event {
        case .orderCompleted:
            router.navigate(to: .home, style: .replaceRoot)
        }
    }
}

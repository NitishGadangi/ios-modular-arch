import UIKit
import CartInterface
import SharedRouterInterface
import AnalyticsLib

public final class CartCoordinator: CartBuildable {
    private let router: SharedRouterProtocol
    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol

    public init(router: SharedRouterProtocol, cartService: CartServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.router = router
        self.cartService = cartService
        self.analytics = analytics
    }

    public func buildCartScreen() -> UIViewController {
        let viewModel = CartViewModel(cartService: cartService, analytics: analytics)
        viewModel.navigationDelegate = self
        return CartViewController(viewModel: viewModel)
    }
}

extension CartCoordinator: CartViewModelNavigationDelegate {
    func cartViewModel(_ viewModel: CartViewModel, didRequest event: CartViewModel.NavigationEvent) {
        switch event {
        case .productSelected(let id):
            router.navigate(to: .productDetail(productId: id), style: .push)
        case .checkoutTapped:
            router.navigate(to: .checkout, style: .push)
        }
    }
}

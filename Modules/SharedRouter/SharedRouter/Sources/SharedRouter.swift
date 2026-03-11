import UIKit
import SharedRouterInterface
import HomeInterface
import DetailsInterface
import CartInterface
import CheckoutInterface

public final class SharedRouter: SharedRouterProtocol {
    private weak var navigationController: UINavigationController?
    private let homeBuilder: HomeBuildable
    private let detailsBuilder: DetailsBuildable
    private let cartBuilder: CartBuildable
    private let checkoutBuilder: CheckoutBuildable

    public init(
        navigationController: UINavigationController,
        homeBuilder: HomeBuildable,
        detailsBuilder: DetailsBuildable,
        cartBuilder: CartBuildable,
        checkoutBuilder: CheckoutBuildable
    ) {
        self.navigationController = navigationController
        self.homeBuilder = homeBuilder
        self.detailsBuilder = detailsBuilder
        self.cartBuilder = cartBuilder
        self.checkoutBuilder = checkoutBuilder
    }

    public func navigate(to route: Route, style: NavigationStyle) {
        let viewController = buildScreen(for: route)
        switch style {
        case .push:
            navigationController?.pushViewController(viewController, animated: true)
        case .present(let fullScreen):
            if fullScreen {
                viewController.modalPresentationStyle = .fullScreen
            }
            navigationController?.present(viewController, animated: true)
        case .replaceRoot:
            navigationController?.setViewControllers([viewController], animated: true)
        }
    }

    private func buildScreen(for route: Route) -> UIViewController {
        switch route {
        case .home:
            return homeBuilder.buildHomeScreen()
        case .productDetail(let productId):
            return detailsBuilder.buildDetailsScreen(productId: productId)
        case .cart:
            return cartBuilder.buildCartScreen()
        case .checkout:
            return checkoutBuilder.buildCheckoutScreen()
        }
    }
}

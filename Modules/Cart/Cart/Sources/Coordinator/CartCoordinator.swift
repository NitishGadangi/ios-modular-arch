import UIKit
import Combine
import CartInterface
import SharedRouterInterface
import AnalyticsLib

public final class CartCoordinator: CartBuildable {
    private let router: SharedRouterProtocol
    private let cartService: CartServiceProtocol
    private let analytics: AnalyticsServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    public init(router: SharedRouterProtocol, cartService: CartServiceProtocol, analytics: AnalyticsServiceProtocol) {
        self.router = router
        self.cartService = cartService
        self.analytics = analytics
    }

    public func buildCartScreen() -> UIViewController {
        let viewModel = CartViewModel(cartService: cartService, analytics: analytics)

        viewModel.navigation.sink { [weak self] event in
            switch event {
            case .productSelected(let id):
                self?.router.navigate(to: .productDetail(productId: id), style: .push)
            case .checkoutTapped:
                self?.router.navigate(to: .checkout, style: .push)
            }
        }.store(in: &cancellables)

        return CartViewController(viewModel: viewModel)
    }
}

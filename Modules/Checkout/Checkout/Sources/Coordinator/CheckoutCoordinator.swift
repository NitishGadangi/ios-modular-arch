import UIKit
import Combine
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

    public func buildCheckoutScreen() -> UIViewController {
        let repository = CheckoutRepository(networkService: networkService)
        let useCase = PlaceOrderUseCase(repository: repository)
        let viewModel = CheckoutViewModel(
            placeOrderUseCase: useCase,
            cartService: cartService,
            analytics: analytics
        )

        viewModel.navigation.sink { [weak self] event in
            switch event {
            case .orderCompleted:
                self?.router.navigate(to: .home, style: .replaceRoot)
            }
        }.store(in: &cancellables)

        return CheckoutViewController(viewModel: viewModel)
    }
}

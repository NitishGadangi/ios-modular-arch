import UIKit
import NetworkLib
import AnalyticsLib
import LoggingLib
import SharedRouterInterface
import SharedRouter
import HomeInterface
import Home
import DetailsInterface
import Details
import CartInterface
import Cart
import CheckoutInterface
import Checkout

final class CompositionRoot {
    private let navigationController: UINavigationController
    private let networkService: NetworkServiceProtocol
    private let analyticsService: AnalyticsServiceProtocol
    private let logger: LoggerProtocol
    private let cartService: CartServiceProtocol

    private var router: SharedRouter!
    private var homeCoordinator: HomeCoordinator!
    private var detailsCoordinator: DetailsCoordinator!
    private var cartCoordinator: CartCoordinator!
    private var checkoutCoordinator: CheckoutCoordinator!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        // Libraries
        self.logger = ConsoleLogger(minimumLevel: .debug)
        self.networkService = MockNetworkService()
        let cache = InMemoryEventCache()
        let dispatcher = ConsoleAnalyticsDispatcher()
        self.analyticsService = EventBatcher(cache: cache, dispatcher: dispatcher, batchSize: 5, flushInterval: 10)
        self.cartService = CartServiceImpl()

        logger.info("CompositionRoot initialized")
    }

    func assembleAndStart() -> UIViewController {
        // Create coordinators (builders) — they need router, but router needs them.
        // Break the cycle: create coordinators first with a temporary reference,
        // then create router, then inject router.
        // We use a two-phase init approach via lazy router injection.

        homeCoordinator = HomeCoordinator(
            router: LazyRouter { [weak self] in self?.router },
            networkService: networkService,
            analytics: analyticsService
        )

        detailsCoordinator = DetailsCoordinator(
            router: LazyRouter { [weak self] in self?.router },
            networkService: networkService,
            cartService: cartService,
            analytics: analyticsService
        )

        cartCoordinator = CartCoordinator(
            router: LazyRouter { [weak self] in self?.router },
            cartService: cartService,
            analytics: analyticsService
        )

        checkoutCoordinator = CheckoutCoordinator(
            router: LazyRouter { [weak self] in self?.router },
            networkService: networkService,
            cartService: cartService,
            analytics: analyticsService
        )

        router = SharedRouter(
            navigationController: navigationController,
            homeBuilder: homeCoordinator,
            detailsBuilder: detailsCoordinator,
            cartBuilder: cartCoordinator,
            checkoutBuilder: checkoutCoordinator
        )

        return homeCoordinator.buildHomeScreen()
    }

    func makeDeeplinkHandler() -> DeeplinkHandler {
        DeeplinkHandler(router: router)
    }
}

// MARK: - LazyRouter

/// Breaks the circular dependency between Router and Coordinators.
/// Coordinators are created with a LazyRouter that resolves to the real router after assembly.
private final class LazyRouter: SharedRouterProtocol {
    private let resolver: () -> SharedRouterProtocol?

    init(_ resolver: @escaping () -> SharedRouterProtocol?) {
        self.resolver = resolver
    }

    func navigate(to route: Route, style: NavigationStyle) {
        resolver()?.navigate(to: route, style: style)
    }
}

import UIKit
import NetworkLib
import AnalyticsLib
import LoggingLib
import ConfigLib
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
    private let configProvider: ConfigProviderProtocol

    private(set) lazy var appConfigurator = AppConfigurator(
        logger: logger,
        config: configProvider,
        analytics: analyticsService,
        networkService: networkService
    )

    private var router: SharedRouter!
    private var homeCoordinator: HomeCoordinator!
    private var detailsCoordinator: DetailsCoordinator!
    private var cartCoordinator: CartCoordinator!
    private var checkoutCoordinator: CheckoutCoordinator!

    private let remoteConfigsUrl =  URL(string: "https://gist.githubusercontent.com/NitishGadangi/2eeab01e7dd1c9941deb64d062b4a94e/raw/3f11bcaebc919963a5bbc2c655ab6976a0e79ad1/modularshop_remote_config.json")!

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController

        // Libraries
        self.logger = ConsoleLogger(minimumLevel: .debug)
        self.configProvider = RemoteConfigProvider(remoteURL: remoteConfigsUrl)
        self.networkService = URLSessionNetworkService()
        let cache = InMemoryEventCache()
        let batcher = EventBatcher(cache: cache, batchSize: 5)
        let dispatcher = ConsoleAnalyticsDispatcher()
        self.analyticsService = AnalyticsService(batcher: batcher, dispatcher: dispatcher, flushInterval: 10)
        self.cartService = CartServiceImpl()

        logger.info("CompositionRoot initialized")
    }

    func assembleAndStart() -> UIViewController {
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

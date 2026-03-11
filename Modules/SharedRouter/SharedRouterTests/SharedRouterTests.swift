import XCTest
import UIKit
import SharedRouterInterface
import HomeInterface
import DetailsInterface
import CartInterface
import CheckoutInterface
@testable import SharedRouter

final class SharedRouterTests: XCTestCase {
    var navigationController: SpyNavigationController!
    var homeBuilder: StubHomeBuildable!
    var detailsBuilder: StubDetailsBuildable!
    var cartBuilder: StubCartBuildable!
    var checkoutBuilder: StubCheckoutBuildable!
    var sut: SharedRouter!

    override func setUp() {
        super.setUp()
        navigationController = SpyNavigationController()
        homeBuilder = StubHomeBuildable()
        detailsBuilder = StubDetailsBuildable()
        cartBuilder = StubCartBuildable()
        checkoutBuilder = StubCheckoutBuildable()
        sut = SharedRouter(
            navigationController: navigationController,
            homeBuilder: homeBuilder,
            detailsBuilder: detailsBuilder,
            cartBuilder: cartBuilder,
            checkoutBuilder: checkoutBuilder
        )
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testNavigateToHomePush() {
        sut.navigate(to: .home, style: .push)
        XCTAssertEqual(navigationController.pushedViewControllers.count, 1)
    }

    func testNavigateToProductDetail() {
        sut.navigate(to: .productDetail(productId: "42"), style: .push)
        XCTAssertEqual(navigationController.pushedViewControllers.count, 1)
        XCTAssertTrue(detailsBuilder.buildCalled)
        XCTAssertEqual(detailsBuilder.lastProductId, "42")
    }

    func testNavigateToCart() {
        sut.navigate(to: .cart, style: .push)
        XCTAssertTrue(cartBuilder.buildCalled)
    }

    func testNavigateToCheckout() {
        sut.navigate(to: .checkout, style: .push)
        XCTAssertTrue(checkoutBuilder.buildCalled)
    }

    func testReplaceRoot() {
        sut.navigate(to: .home, style: .replaceRoot)
        XCTAssertEqual(navigationController.setViewControllersCalled, true)
    }
}

// MARK: - Test Doubles

final class SpyNavigationController: UINavigationController {
    var pushedViewControllers: [UIViewController] = []
    var setViewControllersCalled = false

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        pushedViewControllers.append(viewController)
    }

    override func setViewControllers(_ viewControllers: [UIViewController], animated: Bool) {
        setViewControllersCalled = true
        super.setViewControllers(viewControllers, animated: false)
    }
}

final class StubHomeBuildable: HomeBuildable {
    var buildCalled = false
    func buildHomeScreen() -> UIViewController {
        buildCalled = true
        return UIViewController()
    }
}

final class StubDetailsBuildable: DetailsBuildable {
    var buildCalled = false
    var lastProductId: String?
    func buildDetailsScreen(productId: String) -> UIViewController {
        buildCalled = true
        lastProductId = productId
        return UIViewController()
    }
}

final class StubCartBuildable: CartBuildable {
    var buildCalled = false
    func buildCartScreen() -> UIViewController {
        buildCalled = true
        return UIViewController()
    }
}

final class StubCheckoutBuildable: CheckoutBuildable {
    var buildCalled = false
    func buildCheckoutScreen() -> UIViewController {
        buildCalled = true
        return UIViewController()
    }
}

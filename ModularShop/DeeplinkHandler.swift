import Foundation
import SharedRouterInterface

final class DeeplinkHandler {
    private let router: SharedRouterProtocol

    init(router: SharedRouterProtocol) {
        self.router = router
    }

    func handle(url: URL) -> Bool {
        guard let route = parseRoute(from: url) else { return false }
        router.navigate(to: route, style: .push)
        return true
    }

    private func parseRoute(from url: URL) -> Route? {
        guard url.scheme == "modularshop" else { return nil }

        let pathComponents = url.pathComponents.filter { $0 != "/" }

        switch url.host {
        case "product":
            if let productId = pathComponents.first {
                return .productDetail(productId: productId)
            }
            return nil
        case "cart":
            return .cart
        case "checkout":
            return .checkout
        case "home":
            return .home
        default:
            return nil
        }
    }
}

import UIKit

public protocol DetailsBuildable {
    func buildDetailsScreen(productId: String) -> UIViewController
}

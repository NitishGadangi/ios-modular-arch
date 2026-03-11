import Foundation

public enum Route: Equatable {
    case home
    case productDetail(productId: String)
    case cart
    case checkout
}

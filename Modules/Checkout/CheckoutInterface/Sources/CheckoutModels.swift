import Foundation

public struct OrderSummary: Equatable, Decodable {
    public let orderId: String
    public let status: String
    public let total: Double
    public let estimatedDelivery: String

    public init(orderId: String, status: String, total: Double, estimatedDelivery: String) {
        self.orderId = orderId
        self.status = status
        self.total = total
        self.estimatedDelivery = estimatedDelivery
    }
}

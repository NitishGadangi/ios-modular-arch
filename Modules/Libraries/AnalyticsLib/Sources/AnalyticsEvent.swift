import Foundation

public struct AnalyticsEvent: Equatable {
    public let name: String
    public let parameters: [String: String]
    public let timestamp: Date

    public init(name: String, parameters: [String: String] = [:], timestamp: Date = Date()) {
        self.name = name
        self.parameters = parameters
        self.timestamp = timestamp
    }
}

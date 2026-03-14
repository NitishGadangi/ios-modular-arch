import Foundation

public struct NetworkConfiguration {
    public let baseURL: String
    public let timeoutInterval: TimeInterval
    public let logRequests: Bool

    public init(
        baseURL: String,
        timeoutInterval: TimeInterval = 30,
        logRequests: Bool = false
    ) {
        self.baseURL = baseURL
        self.timeoutInterval = timeoutInterval
        self.logRequests = logRequests
    }
}

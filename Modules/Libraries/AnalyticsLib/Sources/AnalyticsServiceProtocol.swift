import Foundation

public protocol AnalyticsServiceProtocol {
    func track(_ event: AnalyticsEvent)
    func flush()
}

public protocol AnalyticsDispatcherProtocol {
    func dispatch(_ events: [AnalyticsEvent])
}

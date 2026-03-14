import Foundation

public protocol AnalyticsServiceProtocol {
    var isEnabled: Bool { get }
    func setEnabled(_ enabled: Bool)
    func track(_ event: AnalyticsEvent)
    func flush()
}

public protocol AnalyticsDispatcherProtocol {
    func dispatch(_ events: [AnalyticsEvent])
}

import Foundation

public protocol EventCacheProtocol {
    var count: Int { get }
    func store(_ event: AnalyticsEvent)
    func retrieveAll() -> [AnalyticsEvent]
    func clear()
}

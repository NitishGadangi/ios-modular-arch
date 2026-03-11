import Foundation

public final class InMemoryEventCache: EventCacheProtocol {
    private var events: [AnalyticsEvent] = []
    private let lock = NSLock()

    public init() {}

    public var count: Int {
        lock.lock()
        defer { lock.unlock() }
        return events.count
    }

    public func store(_ event: AnalyticsEvent) {
        lock.lock()
        defer { lock.unlock() }
        events.append(event)
    }

    public func retrieveAll() -> [AnalyticsEvent] {
        lock.lock()
        defer { lock.unlock() }
        return events
    }

    public func clear() {
        lock.lock()
        defer { lock.unlock() }
        events.removeAll()
    }
}

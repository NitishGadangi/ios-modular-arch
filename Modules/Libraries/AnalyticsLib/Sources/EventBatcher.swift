import Foundation

public final class EventBatcher {
    private let cache: EventCacheProtocol
    private let batchSize: Int

    public init(cache: EventCacheProtocol, batchSize: Int = 10) {
        self.cache = cache
        self.batchSize = batchSize
    }

    public func add(_ event: AnalyticsEvent) {
        cache.store(event)
    }

    public var shouldFlush: Bool {
        cache.count >= batchSize
    }

    public func drain() -> [AnalyticsEvent] {
        let events = cache.retrieveAll()
        guard !events.isEmpty else { return [] }
        cache.clear()
        return events
    }
}

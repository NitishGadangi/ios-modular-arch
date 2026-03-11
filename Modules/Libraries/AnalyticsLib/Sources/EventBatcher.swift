import Foundation

public final class EventBatcher: AnalyticsServiceProtocol {
    private let cache: EventCacheProtocol
    private let dispatcher: AnalyticsDispatcherProtocol
    private let batchSize: Int
    private let flushInterval: TimeInterval
    private var timer: Timer?

    public init(
        cache: EventCacheProtocol,
        dispatcher: AnalyticsDispatcherProtocol,
        batchSize: Int = 10,
        flushInterval: TimeInterval = 30
    ) {
        self.cache = cache
        self.dispatcher = dispatcher
        self.batchSize = batchSize
        self.flushInterval = flushInterval
        startTimer()
    }

    deinit {
        timer?.invalidate()
    }

    public func track(_ event: AnalyticsEvent) {
        cache.store(event)
        if cache.count >= batchSize {
            flush()
        }
    }

    public func flush() {
        let events = cache.retrieveAll()
        guard !events.isEmpty else { return }
        cache.clear()
        dispatcher.dispatch(events)
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: flushInterval, repeats: true) { [weak self] _ in
            self?.flush()
        }
    }
}

import Foundation

public final class AnalyticsService: AnalyticsServiceProtocol {
    private let batcher: EventBatcher
    private let dispatcher: AnalyticsDispatcherProtocol
    private let queue: DispatchQueue
    private let flushInterval: TimeInterval
    private var timer: DispatchSourceTimer?

    public init(
        batcher: EventBatcher,
        dispatcher: AnalyticsDispatcherProtocol,
        flushInterval: TimeInterval = 30,
        queue: DispatchQueue = DispatchQueue(label: "com.modularshop.analytics", qos: .utility)
    ) {
        self.batcher = batcher
        self.dispatcher = dispatcher
        self.flushInterval = flushInterval
        self.queue = queue
        startTimer()
    }

    deinit {
        timer?.cancel()
    }

    public func track(_ event: AnalyticsEvent) {
        queue.async { [weak self] in
            guard let self else { return }
            self.batcher.add(event)
            if self.batcher.shouldFlush {
                self.performFlush()
            }
        }
    }

    public func flush() {
        queue.async { [weak self] in
            self?.performFlush()
        }
    }

    private func performFlush() {
        let events = batcher.drain()
        guard !events.isEmpty else { return }
        dispatcher.dispatch(events)
    }

    private func startTimer() {
        let source = DispatchSource.makeTimerSource(queue: queue)
        source.schedule(deadline: .now() + flushInterval, repeating: flushInterval)
        source.setEventHandler { [weak self] in
            self?.performFlush()
        }
        source.resume()
        timer = source
    }
}

import XCTest
@testable import AnalyticsLib

final class EventBatcherTests: XCTestCase {
    var cache: InMemoryEventCache!
    var sut: EventBatcher!

    override func setUp() {
        super.setUp()
        cache = InMemoryEventCache()
    }

    override func tearDown() {
        sut = nil
        cache = nil
        super.tearDown()
    }

    func testAddStoresEvent() {
        sut = EventBatcher(cache: cache, batchSize: 10)
        sut.add(AnalyticsEvent(name: "event1"))
        XCTAssertEqual(cache.count, 1)
    }

    func testShouldFlushWhenBatchSizeReached() {
        sut = EventBatcher(cache: cache, batchSize: 2)

        sut.add(AnalyticsEvent(name: "event1"))
        XCTAssertFalse(sut.shouldFlush)

        sut.add(AnalyticsEvent(name: "event2"))
        XCTAssertTrue(sut.shouldFlush)
    }

    func testDrainReturnsEventsAndClearsCache() {
        sut = EventBatcher(cache: cache, batchSize: 10)

        sut.add(AnalyticsEvent(name: "event1"))
        sut.add(AnalyticsEvent(name: "event2"))

        let events = sut.drain()
        XCTAssertEqual(events.count, 2)
        XCTAssertEqual(cache.count, 0)
    }

    func testDrainWithEmptyCacheReturnsEmpty() {
        sut = EventBatcher(cache: cache, batchSize: 10)
        let events = sut.drain()
        XCTAssertTrue(events.isEmpty)
    }
}

final class AnalyticsServiceTests: XCTestCase {
    func testTrackAndFlush() {
        let cache = InMemoryEventCache()
        let batcher = EventBatcher(cache: cache, batchSize: 100)
        let dispatcher = SpyDispatcher()
        let sut = AnalyticsService(batcher: batcher, dispatcher: dispatcher, flushInterval: 999)

        sut.track(AnalyticsEvent(name: "event1"))
        sut.track(AnalyticsEvent(name: "event2"))
        sut.flush()

        let expectation = expectation(description: "Flush dispatched")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        XCTAssertEqual(dispatcher.dispatchedBatches.count, 1)
        XCTAssertEqual(dispatcher.dispatchedBatches.first?.count, 2)
    }

    func testAutoFlushOnBatchSize() {
        let cache = InMemoryEventCache()
        let batcher = EventBatcher(cache: cache, batchSize: 2)
        let dispatcher = SpyDispatcher()
        let sut = AnalyticsService(batcher: batcher, dispatcher: dispatcher, flushInterval: 999)

        sut.track(AnalyticsEvent(name: "event1"))
        sut.track(AnalyticsEvent(name: "event2"))

        let expectation = expectation(description: "Auto flush")
        DispatchQueue.global().asyncAfter(deadline: .now() + 0.5) {
            expectation.fulfill()
        }
        waitForExpectations(timeout: 2)

        XCTAssertGreaterThanOrEqual(dispatcher.dispatchedBatches.count, 1)
    }
}

final class SpyDispatcher: AnalyticsDispatcherProtocol {
    private let lock = NSLock()
    private var _dispatchedBatches: [[AnalyticsEvent]] = []

    var dispatchedBatches: [[AnalyticsEvent]] {
        lock.lock()
        defer { lock.unlock() }
        return _dispatchedBatches
    }

    func dispatch(_ events: [AnalyticsEvent]) {
        lock.lock()
        defer { lock.unlock() }
        _dispatchedBatches.append(events)
    }
}

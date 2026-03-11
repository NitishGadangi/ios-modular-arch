import XCTest
@testable import AnalyticsLib

final class EventBatcherTests: XCTestCase {
    var cache: InMemoryEventCache!
    var dispatcher: SpyDispatcher!
    var sut: EventBatcher!

    override func setUp() {
        super.setUp()
        cache = InMemoryEventCache()
        dispatcher = SpyDispatcher()
    }

    override func tearDown() {
        sut = nil
        dispatcher = nil
        cache = nil
        super.tearDown()
    }

    func testFlushesWhenBatchSizeReached() {
        sut = EventBatcher(cache: cache, dispatcher: dispatcher, batchSize: 3, flushInterval: 999)

        sut.track(AnalyticsEvent(name: "event1"))
        sut.track(AnalyticsEvent(name: "event2"))
        XCTAssertEqual(dispatcher.dispatchedBatches.count, 0)

        sut.track(AnalyticsEvent(name: "event3"))
        XCTAssertEqual(dispatcher.dispatchedBatches.count, 1)
        XCTAssertEqual(dispatcher.dispatchedBatches.first?.count, 3)
    }

    func testManualFlush() {
        sut = EventBatcher(cache: cache, dispatcher: dispatcher, batchSize: 100, flushInterval: 999)

        sut.track(AnalyticsEvent(name: "event1"))
        sut.track(AnalyticsEvent(name: "event2"))
        XCTAssertEqual(dispatcher.dispatchedBatches.count, 0)

        sut.flush()
        XCTAssertEqual(dispatcher.dispatchedBatches.count, 1)
        XCTAssertEqual(dispatcher.dispatchedBatches.first?.count, 2)
    }

    func testFlushWithEmptyCacheDoesNotDispatch() {
        sut = EventBatcher(cache: cache, dispatcher: dispatcher, batchSize: 10, flushInterval: 999)
        sut.flush()
        XCTAssertEqual(dispatcher.dispatchedBatches.count, 0)
    }

    func testCacheIsClearedAfterFlush() {
        sut = EventBatcher(cache: cache, dispatcher: dispatcher, batchSize: 2, flushInterval: 999)

        sut.track(AnalyticsEvent(name: "event1"))
        sut.track(AnalyticsEvent(name: "event2"))

        XCTAssertEqual(cache.count, 0)
    }
}

final class SpyDispatcher: AnalyticsDispatcherProtocol {
    var dispatchedBatches: [[AnalyticsEvent]] = []

    func dispatch(_ events: [AnalyticsEvent]) {
        dispatchedBatches.append(events)
    }
}

import Foundation

public final class ConsoleAnalyticsDispatcher: AnalyticsDispatcherProtocol {
    public init() {}

    public func dispatch(_ events: [AnalyticsEvent]) {
        print("[Analytics] Dispatching \(events.count) events:")
        for event in events {
            let params = event.parameters.map { "\($0.key)=\($0.value)" }.joined(separator: ", ")
            print("  - \(event.name) [\(params)]")
        }
    }
}

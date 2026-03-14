import Foundation

public final class BundledConfigProvider: ConfigProviderProtocol {
    private let config: [String: Any]

    public init(bundle: Bundle = .main) {
        if let url = bundle.url(forResource: "AppConfig", withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url) as? [String: Any] {
            config = dict
        } else {
            config = [:]
        }
    }

    public func bool(for key: ConfigKey) -> Bool {
        config[key.rawValue] as? Bool ?? false
    }

    public func string(for key: ConfigKey) -> String {
        config[key.rawValue] as? String ?? ""
    }

    public func int(for key: ConfigKey) -> Int {
        config[key.rawValue] as? Int ?? 0
    }

    public func double(for key: ConfigKey) -> Double {
        config[key.rawValue] as? Double ?? 0
    }
}

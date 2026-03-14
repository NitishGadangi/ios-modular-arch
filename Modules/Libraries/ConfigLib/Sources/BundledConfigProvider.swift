import Foundation

public final class BundledConfigProvider: ConfigProviderProtocol {
    private let config: [String: Any]

    public var loadedKeyCount: Int { config.count }

    public init(plistName: String = "AppConfig", bundle: Bundle = .main) {
        if let url = bundle.url(forResource: plistName, withExtension: "plist"),
           let dict = NSDictionary(contentsOf: url) as? [String: Any] {
            config = dict
        } else {
            config = [:]
        }
    }

    public func bool(for key: ConfigKey, default defaultValue: Bool = false) -> Bool {
        config[key.rawValue] as? Bool ?? defaultValue
    }

    public func string(for key: ConfigKey, default defaultValue: String = "") -> String {
        config[key.rawValue] as? String ?? defaultValue
    }

    public func int(for key: ConfigKey, default defaultValue: Int = 0) -> Int {
        config[key.rawValue] as? Int ?? defaultValue
    }

    public func double(for key: ConfigKey, default defaultValue: Double = 0) -> Double {
        config[key.rawValue] as? Double ?? defaultValue
    }
}

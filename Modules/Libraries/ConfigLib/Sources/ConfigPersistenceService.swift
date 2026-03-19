import Foundation

public final class ConfigPersistenceService {
    private let defaults: UserDefaults
    private let prefix = "com.modularshop.config."

    public init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func save(_ value: Any, forKey key: String) {
        defaults.set(value, forKey: prefix + key)
    }

    func value(forKey key: String) -> Any? {
        defaults.object(forKey: prefix + key)
    }

    func saveConfigVersion(_ version: Int) {
        defaults.set(version, forKey: prefix + "config_version")
    }

    func configVersion() -> Int {
        defaults.integer(forKey: prefix + "config_version")
    }

    func saveAll(_ configs: [[String: Any]], version: Int) {
        for entry in configs {
            guard let key = entry["key"] as? String else { continue }
            if let val = entry["value"] { save(val, forKey: key) }
        }
        saveConfigVersion(version)
    }
}

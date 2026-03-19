import Foundation

public protocol ConfigProviderProtocol {
    var loadedKeyCount: Int { get }
    func bool(for key: ConfigKey, default defaultValue: Bool) -> Bool
    func string(for key: ConfigKey, default defaultValue: String) -> String
    func int(for key: ConfigKey, default defaultValue: Int) -> Int
    func double(for key: ConfigKey, default defaultValue: Double) -> Double

    /// Load configs into memory. On first launch (empty persistence),
    /// this blocks until remote fetch completes or times out.
    /// On subsequent launches, returns immediately from persisted values
    /// and triggers a background refresh.
    func loadConfig()
}

public extension ConfigProviderProtocol {
    func loadConfig() {}
}

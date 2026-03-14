import Foundation

public protocol ConfigProviderProtocol {
    var loadedKeyCount: Int { get }
    func bool(for key: ConfigKey, default defaultValue: Bool) -> Bool
    func string(for key: ConfigKey, default defaultValue: String) -> String
    func int(for key: ConfigKey, default defaultValue: Int) -> Int
    func double(for key: ConfigKey, default defaultValue: Double) -> Double
}

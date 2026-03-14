import Foundation

public protocol ConfigProviderProtocol {
    func bool(for key: ConfigKey) -> Bool
    func string(for key: ConfigKey) -> String
    func int(for key: ConfigKey) -> Int
    func double(for key: ConfigKey) -> Double
}

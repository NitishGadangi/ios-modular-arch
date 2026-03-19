import Foundation

public final class RemoteConfigProvider: ConfigProviderProtocol {
    private let remoteURL: URL
    private let persistence: ConfigPersistenceService
    private var inMemoryConfig: [String: Any] = [:]
    private let fetchTimeoutSeconds: Double

    public var loadedKeyCount: Int { inMemoryConfig.count }

    public init(
        remoteURL: URL,
        persistence: ConfigPersistenceService = ConfigPersistenceService(),
        fetchTimeoutSeconds: Double = 5.0
    ) {
        self.remoteURL = remoteURL
        self.persistence = persistence
        self.fetchTimeoutSeconds = fetchTimeoutSeconds
    }

    // MARK: - loadConfig

    /// Loads config into memory. If UserDefaults has persisted values,
    /// loads them immediately and fires a background refresh.
    /// If UserDefaults is empty (first launch), blocks the caller
    /// until remote fetch completes or times out.
    public func loadConfig() {
        loadFromPersistence()

        if inMemoryConfig.isEmpty {
            // First launch — wait synchronously for remote fetch
            fetchRemoteSync()
        } else {
            // Subsequent launches — refresh in background
            fetchRemoteAsync()
        }
    }

    // MARK: - Persistence

    private func loadFromPersistence() {
        for key in ConfigKey.allCases {
            if let value = persistence.value(forKey: key.rawValue) {
                inMemoryConfig[key.rawValue] = value
            }
        }
    }

    // MARK: - Remote Fetch

    /// Blocking fetch with timeout — used only on first launch.
    private func fetchRemoteSync() {
        let semaphore = DispatchSemaphore(value: 0)

        URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, error in
            defer { semaphore.signal() }
            self?.handleRemoteResponse(data: data, error: error)
        }.resume()

        _ = semaphore.wait(timeout: .now() + fetchTimeoutSeconds)
    }

    /// Non-blocking fetch — used on subsequent launches.
    private func fetchRemoteAsync() {
        URLSession.shared.dataTask(with: remoteURL) { [weak self] data, _, error in
            self?.handleRemoteResponse(data: data, error: error)
        }.resume()
    }

    private func handleRemoteResponse(data: Data?, error: Error?) {
        guard let data, error == nil else { return }
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
              let configs = json["configs"] as? [[String: Any]],
              let version = json["config_version"] as? Int else { return }

        persistence.saveAll(configs, version: version)
        loadFromPersistence()
    }

    // MARK: - ConfigProviderProtocol

    public func bool(for key: ConfigKey, default defaultValue: Bool) -> Bool {
        inMemoryConfig[key.rawValue] as? Bool ?? defaultValue
    }

    public func string(for key: ConfigKey, default defaultValue: String) -> String {
        inMemoryConfig[key.rawValue] as? String ?? defaultValue
    }

    public func int(for key: ConfigKey, default defaultValue: Int) -> Int {
        inMemoryConfig[key.rawValue] as? Int ?? defaultValue
    }

    public func double(for key: ConfigKey, default defaultValue: Double) -> Double {
        inMemoryConfig[key.rawValue] as? Double ?? defaultValue
    }
}

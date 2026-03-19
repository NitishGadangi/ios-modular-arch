import UIKit
import LoggingLib
import AnalyticsLib
import NetworkLib
import ConfigLib

final class AppConfigurator {
    private var logger: LoggerProtocol
    private let config: ConfigProviderProtocol
    private let analytics: AnalyticsServiceProtocol
    private let networkService: NetworkServiceProtocol

    init(
        logger: LoggerProtocol,
        config: ConfigProviderProtocol,
        analytics: AnalyticsServiceProtocol,
        networkService: NetworkServiceProtocol
    ) {
        self.logger = logger
        self.config = config
        self.analytics = analytics
        self.networkService = networkService
    }

    func performLaunchSetup() {
        let startTime = CFAbsoluteTimeGetCurrent()

        setupConfig()
        setupLogging()
        setupNetwork()
        setupAnalytics()
        setupAppearance()

        let durationMs = (CFAbsoluteTimeGetCurrent() - startTime) * 1000
        logger.info("App launch setup completed in \(String(format: "%.2f", durationMs))ms")
    }

    // MARK: - Setup Steps

    private func setupConfig() {
        config.loadConfig()
        logger.info("Config loaded: \(config.loadedKeyCount) keys, remote fetch triggered")
    }

    private func setupLogging() {
        let levelString = config.string(for: .logLevel, default: "debug")
        logger.minimumLevel = logLevel(from: levelString)
        logger.info("Logging configured: level=\(levelString)")
    }

    private func setupNetwork() {
        let baseURL = config.string(for: .apiBaseURL, default: "https://api.modularshop.dev/v1")
        let timeout = config.double(for: .networkTimeoutSeconds, default: 30)

        #if DEBUG
        let logRequests = true
        #else
        let logRequests = false
        #endif

        let configuration = NetworkConfiguration(
            baseURL: baseURL,
            timeoutInterval: timeout,
            logRequests: logRequests,
            logResponses: logRequests
        )
        networkService.configure(with: configuration)
        logger.info("Network configured: baseURL=\(baseURL), timeout=\(timeout)s, logRequests=\(logRequests)")
    }

    private func setupAnalytics() {
        let enabled = config.bool(for: .analyticsEnabled, default: true)
        analytics.setEnabled(enabled)
        if enabled {
            analytics.track(AnalyticsEvent(name: "app_launched", parameters: [:]))
        }
        logger.info("Analytics configured: enabled=\(enabled)")
    }

    private func setupAppearance() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithDefaultBackground()
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().tintColor = .systemBlue

        logger.info("Appearance configured")
    }

    // MARK: - Helpers

    private func logLevel(from string: String) -> LogLevel {
        switch string.lowercased() {
        case "debug": return .debug
        case "info": return .info
        case "warning": return .warning
        case "error": return .error
        default: return .debug
        }
    }
}
